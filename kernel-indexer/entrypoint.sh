#!/bin/bash
set -euo pipefail

# Exit codes
EXIT_SUCCESS=0
EXIT_GENERAL_ERROR=1
EXIT_MISSING_DEPS=2
EXIT_KERNEL_ROOT_INVALID=3
EXIT_INDEX_FAILED=4
EXIT_COLLATE_FAILED=5

# Default configuration
DEFAULT_KERNEL_ROOT="/sw/icrn/jupyter/icrn_ncsa_resources/Kernels"

# Environment variables with defaults
KERNEL_ROOT="${KERNEL_ROOT:-${DEFAULT_KERNEL_ROOT}}"
OUTPUT_DIR="${OUTPUT_DIR:-${KERNEL_ROOT}}"
LANGUAGE_FILTER="${LANGUAGE_FILTER:-}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
ATOMIC_WRITES="${ATOMIC_WRITES:-true}"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[${timestamp}] [${level}] ${message}"
}

log_info() {
    if [[ "${LOG_LEVEL}" == "DEBUG" ]] || [[ "${LOG_LEVEL}" == "INFO" ]]; then
        log "INFO" "$@"
    fi
}

log_error() {
    log "ERROR" "$@" >&2
}

log_warn() {
    if [[ "${LOG_LEVEL}" != "ERROR" ]]; then
        log "WARN" "$@" >&2
    fi
}

log_debug() {
    if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
        log "DEBUG" "$@"
    fi
}

# Validation functions
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed or not in PATH"
        exit $EXIT_MISSING_DEPS
    fi
    
    if ! command -v conda &> /dev/null; then
        log_error "conda is not installed or not in PATH"
        exit $EXIT_MISSING_DEPS
    fi
    
    if ! command -v kernel_indexer &> /dev/null; then
        log_error "kernel_indexer script is not found or not in PATH"
        exit $EXIT_MISSING_DEPS
    fi
    
    if [ ! -x "$(command -v kernel_indexer)" ]; then
        log_error "kernel_indexer script is not executable"
        exit $EXIT_MISSING_DEPS
    fi
    
    log_info "All dependencies found"
}

validate_kernel_root() {
    log_info "Validating kernel root: ${KERNEL_ROOT}"
    
    # Check if directory exists (do NOT create it - this is core infrastructure)
    if [ ! -d "${KERNEL_ROOT}" ]; then
        log_error "Kernel root directory does not exist: ${KERNEL_ROOT}"
        log_error "This is core infrastructure - if missing, something is seriously wrong"
        exit $EXIT_KERNEL_ROOT_INVALID
    fi
    
    # Check if directory is readable
    if [ ! -r "${KERNEL_ROOT}" ]; then
        log_error "Kernel root directory is not readable: ${KERNEL_ROOT}"
        exit $EXIT_KERNEL_ROOT_INVALID
    fi
    
    # Check if directory is writable (needed for writing manifests)
    if [ ! -w "${KERNEL_ROOT}" ]; then
        log_error "Kernel root directory is not writable: ${KERNEL_ROOT}"
        log_error "Write access is required to create package_manifest.json files"
        exit $EXIT_KERNEL_ROOT_INVALID
    fi
    
    log_info "Kernel root validation passed"
}

validate_output_dir() {
    log_info "Validating output directory: ${OUTPUT_DIR}"
    
    # Check if output directory exists
    if [ ! -d "${OUTPUT_DIR}" ]; then
        log_error "Output directory does not exist: ${OUTPUT_DIR}"
        exit $EXIT_KERNEL_ROOT_INVALID
    fi
    
    # Check if output directory is writable
    if [ ! -w "${OUTPUT_DIR}" ]; then
        log_error "Output directory is not writable: ${OUTPUT_DIR}"
        exit $EXIT_KERNEL_ROOT_INVALID
    fi
    
    log_info "Output directory validation passed"
}

# Validate collated file
validate_collated_file() {
    local output_file="$1"
    local file_description="$2"
    
    log_info "Validating ${file_description}: ${output_file}"
    
    # Check if file exists
    if [ ! -f "${output_file}" ]; then
        log_error "${file_description} not found: ${output_file}"
        return 1
    fi
    
    # Validate JSON structure
    if ! jq '.' "${output_file}" >/dev/null 2>&1; then
        log_error "Invalid JSON in ${file_description}: ${output_file}"
        return 1
    fi
    
    # Get file size for logging (portable approach)
    local file_size
    if command -v stat &> /dev/null; then
        file_size=$(stat -f%z "${output_file}" 2>/dev/null || stat -c%s "${output_file}" 2>/dev/null || wc -c < "${output_file}" 2>/dev/null || echo "unknown")
    else
        file_size=$(wc -c < "${output_file}" 2>/dev/null || echo "unknown")
    fi
    log_info "${file_description} validated successfully (size: ${file_size} bytes)"
    return 0
}

# Main execution
main() {
    log_info "Starting kernel indexer container"
    log_info "KERNEL_ROOT: ${KERNEL_ROOT}"
    log_info "OUTPUT_DIR: ${OUTPUT_DIR}"
    if [ -n "${LANGUAGE_FILTER}" ]; then
        log_info "LANGUAGE_FILTER: ${LANGUAGE_FILTER}"
    else
        log_info "LANGUAGE_FILTER: (all languages)"
    fi
    
    # Validation phase
    check_dependencies
    validate_kernel_root
    validate_output_dir
    
    # Build index command
    local index_cmd="kernel_indexer index --kernel-root '${KERNEL_ROOT}'"
    if [ -n "${LANGUAGE_FILTER}" ]; then
        index_cmd="${index_cmd} --language '${LANGUAGE_FILTER}'"
    fi
    
    # Build collate command
    local collate_cmd="kernel_indexer collate --kernel-root '${KERNEL_ROOT}' --output-dir '${OUTPUT_DIR}'"
    if [ -n "${LANGUAGE_FILTER}" ]; then
        collate_cmd="${collate_cmd} --language '${LANGUAGE_FILTER}'"
    fi
    
    # Execute indexing phase
    log_info "Starting indexing phase..."
    log_debug "Command: ${index_cmd}"
    
    if eval "${index_cmd}"; then
        log_info "Indexing phase completed successfully"
    else
        local exit_code=$?
        log_error "Indexing phase failed with exit code: ${exit_code}"
        exit $EXIT_INDEX_FAILED
    fi
    
    # Execute collation phase
    log_info "Starting collation phase..."
    log_debug "Command: ${collate_cmd}"
    
    # If atomic writes are enabled, we need to intercept the output
    # kernel_indexer writes directly, so we'll validate after
    if eval "${collate_cmd}"; then
        log_info "Collation command completed"
        
        # Validate collated files
        log_info "Validating collated output files..."
        
        local collated_manifests="${OUTPUT_DIR}/collated_manifests.json"
        local package_index="${OUTPUT_DIR}/package_index.json"
        
        if ! validate_collated_file "${collated_manifests}" "collated manifests"; then
            exit $EXIT_COLLATE_FAILED
        fi
        
        if ! validate_collated_file "${package_index}" "package index"; then
            exit $EXIT_COLLATE_FAILED
        fi
        
        log_info "All collated files validated successfully"
        
        log_info "Collation phase completed successfully"
    else
        local exit_code=$?
        log_error "Collation phase failed with exit code: ${exit_code}"
        exit $EXIT_COLLATE_FAILED
    fi
    
    log_info "Kernel indexing completed successfully"
    exit $EXIT_SUCCESS
}

# Run main function
main "$@"

