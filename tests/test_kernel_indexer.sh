#!/bin/bash

# Test file for kernel_indexer functionality

source "$(dirname "$0")/test_common.sh"

KERNEL_INDEXER="$PROJECT_ROOT/kernel_indexer"

# Helper function to setup mock conda command
setup_mock_conda_cmd() {
    # Create a mock conda command that returns specified packages
    local mock_conda="$TEST_BASE/conda"
    cat > "$mock_conda" << 'MOCKCONDA'
#!/bin/bash
# Mock conda command for testing
# Handle: conda run -p <path> conda list --json
if [ "$1" = "run" ] && [ "$2" = "-p" ] && [ "$4" = "conda" ] && [ "$5" = "list" ] && [ "$6" = "--json" ]; then
    # Get kernel path from $3
    local kernel_path="$3"
    # Return packages from a file in the kernel directory
    if [ -f "$kernel_path/conda-meta/.packages.json" ]; then
        cat "$kernel_path/conda-meta/.packages.json"
        exit 0
    else
        echo "[]"
        exit 0
    fi
else
    # For type -p conda check (just returns the command path)
    if [ -z "$1" ]; then
        echo "$0"
        exit 0
    fi
    # Default: exit successfully to pass type -p check
    exit 0
fi
MOCKCONDA
    chmod +x "$mock_conda"
    
    # Ensure mock conda is in PATH before kernel_indexer runs
    export PATH="$TEST_BASE:$PATH"
}

# Helper function to setup mock conda environment
setup_mock_conda_env() {
    local kernel_path=$1
    local packages_json=$2
    
    # Create conda-meta directory
    mkdir -p "$kernel_path/conda-meta"
    
    # Setup mock conda command (only once)
    if [ ! -f "$TEST_BASE/conda" ]; then
        setup_mock_conda_cmd
    fi
    
    # Write packages to a file the mock conda can read
    if [ -n "$packages_json" ]; then
        echo "$packages_json" > "$kernel_path/conda-meta/.packages.json"
    else
        echo "[]" > "$kernel_path/conda-meta/.packages.json"
    fi
}

# Helper function to setup mock R environment
setup_mock_r_env() {
    local kernel_path=$1
    local r_version=$2
    local packages_list=$3
    
    mkdir -p "$kernel_path/bin"
    
    # Create mock Rscript that handles the actual R commands used by kernel_indexer
    local mock_rscript="$kernel_path/bin/Rscript"
    cat > "$mock_rscript" << EOF
#!/bin/bash
# Mock Rscript for testing
# Handle: Rscript --vanilla -e 'cat(R.version\$major, ".", R.version\$minor, sep="")'
# Handle: Rscript --vanilla -e 'installed.packages()...'
if [ "\$1" = "--vanilla" ] && [ "\$2" = "-e" ]; then
    local cmd="\$3"
    # Check if it's the R.version command
    if echo "\$cmd" | grep -q "R.version"; then
        # Return R version (e.g., "4.3")
        echo "$r_version"
        exit 0
    elif echo "\$cmd" | grep -q "installed.packages"; then
        # Return R packages in pipe-delimited format: package|version
        if [ -f "$kernel_path/.r_packages.txt" ]; then
            cat "$kernel_path/.r_packages.txt"
            exit 0
        else
            # Return empty if no packages
            exit 0
        fi
    fi
fi
# Default: fail for unrecognized commands
echo "Rscript: unrecognized command" >&2
exit 1
EOF
    chmod +x "$mock_rscript"
    
    # Create mock R binary
    cat > "$kernel_path/bin/R" << 'EOF'
#!/bin/bash
# Mock R binary
exit 0
EOF
    chmod +x "$kernel_path/bin/R"
    
    # Write R packages to file (pipe-delimited format)
    if [ -n "$packages_list" ]; then
        echo "$packages_list" > "$kernel_path/.r_packages.txt"
    else
        touch "$kernel_path/.r_packages.txt"
    fi
}

# Helper function to setup mock Python environment
setup_mock_python_env() {
    local kernel_path=$1
    local python_version=$2
    
    mkdir -p "$kernel_path/bin"
    
    # Create mock python
    local mock_python="$kernel_path/bin/python"
    cat > "$mock_python" << EOF
#!/bin/bash
if [ "\$1" = "--version" ]; then
    echo "Python $python_version"
else
    echo "python error" >&2
    exit 1
fi
EOF
    chmod +x "$mock_python"
    
    # Also create python3 symlink if python doesn't exist
    if [ ! -f "$kernel_path/bin/python3" ]; then
        ln -sf python "$kernel_path/bin/python3"
    fi
}

# Helper function to verify manifest structure
verify_manifest_structure() {
    local manifest_file=$1
    
    if [ ! -f "$manifest_file" ]; then
        return 1
    fi
    
    # Check if it's valid JSON
    if ! jq '.' "$manifest_file" >/dev/null 2>&1; then
        return 1
    fi
    
    # Check required fields
    local has_name=$(jq -e '.kernel_name' "$manifest_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    local has_version=$(jq -e '.kernel_version' "$manifest_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    local has_language=$(jq -e '.language' "$manifest_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    local has_packages=$(jq -e '.packages' "$manifest_file" >/dev/null 2>&1 && echo "yes" || echo "no")
    
    if [ "$has_name" = "yes" ] && [ "$has_version" = "yes" ] && [ "$has_language" = "yes" ] && [ "$has_packages" = "yes" ]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# Phase 1: Prerequisites and Setup Tests
# ============================================================================

test_indexer_help_display() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    local output
    output=$("$KERNEL_INDEXER" 2>&1)
    
    if echo "$output" | grep -q "usage:" && \
       echo "$output" | grep -q "index" && \
       echo "$output" | grep -q "collate"; then
        return 0
    else
        echo "Help output: $output"
        return 1
    fi
}

test_indexer_no_command() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    local output
    output=$("$KERNEL_INDEXER" 2>&1)
    local exit_code=$?
    
    # Should show help and exit with error
    if echo "$output" | grep -q "usage:" && [ $exit_code -ne 0 ]; then
        return 0
    else
        echo "No command output: $output"
        echo "Exit code: $exit_code"
        return 1
    fi
}

test_indexer_invalid_command() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    local output
    output=$("$KERNEL_INDEXER" invalid_command 2>&1)
    local exit_code=$?
    
    if echo "$output" | grep -q "ERROR: Unknown command" && [ $exit_code -ne 0 ]; then
        return 0
    else
        echo "Invalid command output: $output"
        echo "Exit code: $exit_code"
        return 1
    fi
}

# ============================================================================
# Phase 2: Command Validation Tests
# ============================================================================

test_indexer_index_missing_kernel_root() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    # Clear any default config
    unset DEFAULT_KERNEL_ROOT
    rm -f "$ICRN_USER_BASE/manager_config.json"
    
    local output
    output=$("$KERNEL_INDEXER" index 2>&1)
    local exit_code=$?
    
    if echo "$output" | grep -q "ERROR: --kernel-root is required" && [ $exit_code -ne 0 ]; then
        return 0
    else
        echo "Missing kernel root output: $output"
        echo "Exit code: $exit_code"
        return 1
    fi
}

test_indexer_index_invalid_option() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    local output
    output=$("$KERNEL_INDEXER" index --invalid-option value 2>&1)
    local exit_code=$?
    
    if echo "$output" | grep -q "ERROR: Unknown option" && [ $exit_code -ne 0 ]; then
        return 0
    else
        echo "Invalid option output: $output"
        echo "Exit code: $exit_code"
        return 1
    fi
}

test_indexer_index_kernel_version_without_name() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$TEST_REPO" --kernel-version 1.0 2>&1)
    local exit_code=$?
    
    if echo "$output" | grep -q "ERROR: --kernel-version requires --kernel-name" && [ $exit_code -ne 0 ]; then
        return 0
    else
        echo "Version without name output: $output"
        echo "Exit code: $exit_code"
        return 1
    fi
}

# ============================================================================
# Phase 3: Kernel Discovery Tests
# ============================================================================

test_indexer_discover_kernels_missing_root() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "/nonexistent/path" 2>&1)
    
    if echo "$output" | grep -q "WARNING: Kernel root directory does not exist" || \
       echo "$output" | grep -q "No kernels found"; then
        return 0
    else
        echo "Missing root output: $output"
        return 1
    fi
}

test_indexer_discover_kernels_empty_directory() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    # Create empty directory structure
    local empty_repo="$TEST_BASE/empty_repo"
    mkdir -p "$empty_repo"
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$empty_repo" 2>&1)
    
    if echo "$output" | grep -q "No kernels found" || \
       echo "$output" | grep -q "error discovering kernels"; then
        return 0
    else
        echo "Empty directory output: $output"
        return 1
    fi
}

test_indexer_discover_kernels_invalid_structure() {
    setup_test_env
    set_test_env
    
    # Setup mock conda so script can run
    setup_mock_conda_cmd
    
    # Create directory without conda-meta
    local invalid_kernel="$TEST_REPO/R/test_kernel/1.0"
    mkdir -p "$invalid_kernel/bin"
    touch "$invalid_kernel/bin/Rscript"
    chmod +x "$invalid_kernel/bin/Rscript"
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$TEST_REPO" 2>&1)
    
    # Should not discover this kernel (no conda-meta)
    if echo "$output" | grep -q "Discovering kernels" && \
       ! echo "$output" | grep -q "test_kernel"; then
        return 0
    else
        echo "Invalid structure output: $output"
        return 1
    fi
}

# ============================================================================
# Phase 4: Kernel Indexing Tests
# ============================================================================

test_indexer_index_r_kernel_success() {
    setup_test_env
    set_test_env
    
    # Setup kernel repository with proper structure
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/test_r_kernel/1.0"
    local kernel_path="$kernel_root/R/test_r_kernel/1.0"
    
    # Setup mock conda with packages
    local conda_packages='[{"name": "r-base", "version": "4.3.0", "source": "conda"}, {"name": "r-essentials", "version": "1.0", "source": "conda"}]'
    setup_mock_conda_env "$kernel_path" "$conda_packages"
    
    # Setup mock R environment
    setup_mock_r_env "$kernel_path" "4.3" "cowsay|1.0.1
ggplot2|3.4.0"
    
    # Ensure mock conda is in PATH (setup_mock_conda_env does this)
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$kernel_root" 2>&1)
    
    local manifest_file="$kernel_path/package_manifest.json"
    
    if [ -f "$manifest_file" ] && \
       verify_manifest_structure "$manifest_file" && \
       echo "$output" | grep -q "Indexing kernel" && \
       jq -e '.language == "R"' "$manifest_file" >/dev/null 2>&1 && \
       jq -e '.kernel_name == "test_r_kernel"' "$manifest_file" >/dev/null 2>&1 && \
       jq -e '.kernel_version == "1.0"' "$manifest_file" >/dev/null 2>&1; then
        return 0
    else
        echo "Index R output: $output"
        if [ -f "$manifest_file" ]; then
            echo "Manifest content: $(cat "$manifest_file")"
        fi
        return 1
    fi
}

test_indexer_index_python_kernel_success() {
    setup_test_env
    set_test_env
    
    # Setup kernel repository
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/Python/test_py_kernel/1.0"
    local kernel_path="$kernel_root/Python/test_py_kernel/1.0"
    
    # Setup mock conda environment
    local conda_packages='[{"name": "python", "version": "3.11.0", "source": "conda"}, {"name": "numpy", "version": "1.24.0", "source": "conda"}]'
    setup_mock_conda_env "$kernel_path" "$conda_packages"
    
    # Setup mock Python environment
    setup_mock_python_env "$kernel_path" "3.11.0"
    
    # Ensure mock conda is in PATH
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$kernel_root" --language Python 2>&1)
    
    local manifest_file="$kernel_path/package_manifest.json"
    
    if [ -f "$manifest_file" ] && \
       verify_manifest_structure "$manifest_file" && \
       echo "$output" | grep -q "Indexing kernel" && \
       jq -e '.language == "Python"' "$manifest_file" >/dev/null 2>&1 && \
       jq -e '.kernel_name == "test_py_kernel"' "$manifest_file" >/dev/null 2>&1; then
        return 0
    else
        echo "Index Python output: $output"
        if [ -f "$manifest_file" ]; then
            echo "Manifest content: $(cat "$manifest_file")"
        fi
        return 1
    fi
}

test_indexer_index_r_kernel_missing_rscript() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/test_r_kernel/1.0"
    local kernel_path="$kernel_root/R/test_r_kernel/1.0"
    
    # Create conda-meta but no R binaries
    mkdir -p "$kernel_path/conda-meta"
    local conda_packages='[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_conda_env "$kernel_path" "$conda_packages"
    
    # Don't create R binaries - should fail
    # Ensure mock conda is in PATH
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$kernel_root" --language R 2>&1)
    
    if echo "$output" | grep -q "ERROR: R/Rscript not found" || \
       echo "$output" | grep -q "Failed to index"; then
        return 0
    else
        echo "Missing Rscript output: $output"
        return 1
    fi
}

test_indexer_index_filters_by_name() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    
    # Create two kernels
    mkdir -p "$kernel_root/R/kernel1/1.0/conda-meta"
    mkdir -p "$kernel_root/R/kernel2/1.0/conda-meta"
    
    local kernel1_path="$kernel_root/R/kernel1/1.0"
    local kernel2_path="$kernel_root/R/kernel2/1.0"
    
    setup_mock_conda_env "$kernel1_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_conda_env "$kernel2_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_r_env "$kernel1_path" "4.3" ""
    setup_mock_r_env "$kernel2_path" "4.3" ""
    
    # Ensure mock conda is in PATH
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$kernel_root" --kernel-name kernel1 2>&1)
    
    if [ -f "$kernel1_path/package_manifest.json" ] && \
       [ ! -f "$kernel2_path/package_manifest.json" ] && \
       echo "$output" | grep -q "kernel1"; then
        return 0
    else
        echo "Filter by name output: $output"
        return 1
    fi
}

test_indexer_index_filters_by_version() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    
    # Create kernel with two versions
    mkdir -p "$kernel_root/R/test_kernel/1.0/conda-meta"
    mkdir -p "$kernel_root/R/test_kernel/2.0/conda-meta"
    
    local kernel1_path="$kernel_root/R/test_kernel/1.0"
    local kernel2_path="$kernel_root/R/test_kernel/2.0"
    
    setup_mock_conda_env "$kernel1_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_conda_env "$kernel2_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_r_env "$kernel1_path" "4.3" ""
    setup_mock_r_env "$kernel2_path" "4.3" ""
    
    # Ensure mock conda is in PATH
    
    local output
    output=$("$KERNEL_INDEXER" index --kernel-root "$kernel_root" --kernel-name test_kernel --kernel-version 1.0 2>&1)
    
    if [ -f "$kernel1_path/package_manifest.json" ] && \
       [ ! -f "$kernel2_path/package_manifest.json" ] && \
       echo "$output" | grep -q "test_kernel.*1.0"; then
        return 0
    else
        echo "Filter by version output: $output"
        return 1
    fi
}

# ============================================================================
# Phase 5: Collation Tests
# ============================================================================

test_indexer_collate_kernels_success() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/kernel1/1.0"
    mkdir -p "$kernel_root/R/kernel2/1.0"
    
    local kernel1_path="$kernel_root/R/kernel1/1.0"
    local kernel2_path="$kernel_root/R/kernel2/1.0"
    
    # Setup environments and index kernels
    setup_mock_conda_env "$kernel1_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_conda_env "$kernel2_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_r_env "$kernel1_path" "4.3" ""
    setup_mock_r_env "$kernel2_path" "4.3" ""
    
    # Ensure mock conda is in PATH
    
    # Index kernels first
    "$KERNEL_INDEXER" index --kernel-root "$kernel_root" >/dev/null 2>&1
    
    # Now collate
    local output_path="$TEST_BASE/collated.json"
    local output
    output=$("$KERNEL_INDEXER" collate-by-kernels --kernel-root "$kernel_root" --output "$output_path" 2>&1)
    
    if [ -f "$output_path" ] && \
       jq '.' "$output_path" >/dev/null 2>&1 && \
       jq -e '.kernels | length > 0' "$output_path" >/dev/null 2>&1 && \
       jq -e '.total_kernels' "$output_path" >/dev/null 2>&1; then
        return 0
    else
        echo "Collate kernels output: $output"
        if [ -f "$output_path" ]; then
            echo "Collated content: $(cat "$output_path")"
        fi
        return 1
    fi
}

test_indexer_collate_packages_success() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/kernel1/1.0"
    mkdir -p "$kernel_root/R/kernel2/1.0"
    
    local kernel1_path="$kernel_root/R/kernel1/1.0"
    local kernel2_path="$kernel_root/R/kernel2/1.0"
    
    # Setup environments with overlapping packages
    setup_mock_conda_env "$kernel1_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_conda_env "$kernel2_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_r_env "$kernel1_path" "4.3" "cowsay|1.0"
    setup_mock_r_env "$kernel2_path" "4.3" "cowsay|1.0"
    
    # Ensure mock conda is in PATH
    
    # Index kernels first
    "$KERNEL_INDEXER" index --kernel-root "$kernel_root" >/dev/null 2>&1
    
    # Now collate by packages
    local output_path="$TEST_BASE/package_index.json"
    local output
    output=$("$KERNEL_INDEXER" collate-by-packages --kernel-root "$kernel_root" --output "$output_path" 2>&1)
    
    if [ -f "$output_path" ] && \
       jq '.' "$output_path" >/dev/null 2>&1 && \
       jq -e '.packages' "$output_path" >/dev/null 2>&1 && \
       jq -e '.total_packages' "$output_path" >/dev/null 2>&1; then
        return 0
    else
        echo "Collate packages output: $output"
        if [ -f "$output_path" ]; then
            echo "Package index content: $(cat "$output_path")"
        fi
        return 1
    fi
}

test_indexer_collate_missing_manifests() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/kernel1/1.0/conda-meta"
    
    # Kernel exists but no manifest
    setup_mock_conda_cmd
    
    local output_path="$TEST_BASE/collated.json"
    local output
    output=$("$KERNEL_INDEXER" collate-by-kernels --kernel-root "$kernel_root" --output "$output_path" 2>&1)
    
    # Should handle gracefully (skip or create empty)
    if echo "$output" | grep -q "WARNING: Manifest not found" || \
       echo "$output" | grep -q "No kernels found"; then
        return 0
    else
        echo "Missing manifests output: $output"
        return 1
    fi
}

test_indexer_collate_both_outputs() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/kernel1/1.0"
    
    local kernel1_path="$kernel_root/R/kernel1/1.0"
    setup_mock_conda_env "$kernel1_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_r_env "$kernel1_path" "4.3" ""
    
    # Ensure mock conda is in PATH
    
    # Index first
    "$KERNEL_INDEXER" index --kernel-root "$kernel_root" >/dev/null 2>&1
    
    # Collate (both outputs)
    local output_dir="$TEST_BASE/output"
    mkdir -p "$output_dir"
    local output
    output=$("$KERNEL_INDEXER" collate --kernel-root "$kernel_root" --output-dir "$output_dir" 2>&1)
    
    if [ -f "$output_dir/collated_manifests.json" ] && \
       [ -f "$output_dir/package_index.json" ] && \
       echo "$output" | grep -q "collate-by-kernels" && \
       echo "$output" | grep -q "collate-by-packages"; then
        return 0
    else
        echo "Collate both output: $output"
        return 1
    fi
}

test_indexer_collate_language_filter() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/kernel1/1.0"
    mkdir -p "$kernel_root/Python/kernel2/1.0"
    
    local kernel1_path="$kernel_root/R/kernel1/1.0"
    local kernel2_path="$kernel_root/Python/kernel2/1.0"
    
    setup_mock_conda_env "$kernel1_path" '[{"name": "r-base", "version": "4.3.0"}]'
    setup_mock_conda_env "$kernel2_path" '[{"name": "python", "version": "3.11.0"}]'
    setup_mock_r_env "$kernel1_path" "4.3" ""
    setup_mock_python_env "$kernel2_path" "3.11.0"
    
    # Ensure mock conda is in PATH
    
    # Index both
    "$KERNEL_INDEXER" index --kernel-root "$kernel_root" >/dev/null 2>&1
    
    # Collate only R
    local output_path="$TEST_BASE/collated.json"
    local output
    output=$("$KERNEL_INDEXER" collate-by-kernels --kernel-root "$kernel_root" --language R --output "$output_path" 2>&1)
    
    if [ -f "$output_path" ] && \
       jq -e '[.kernels[] | select(.language == "R")] | length > 0' "$output_path" >/dev/null 2>&1 && \
       ! jq -e '[.kernels[] | select(.language == "Python")] | length > 0' "$output_path" >/dev/null 2>&1; then
        return 0
    else
        echo "Language filter output: $output"
        if [ -f "$output_path" ]; then
            echo "Collated content: $(cat "$output_path")"
        fi
        return 1
    fi
}

# ============================================================================
# Phase 6: Error Handling Tests
# ============================================================================

test_indexer_error_invalid_manifest_json() {
    setup_test_env
    set_test_env
    
    local kernel_root="$TEST_BASE/index_repo"
    mkdir -p "$kernel_root/R/kernel1/1.0"
    
    local kernel1_path="$kernel_root/R/kernel1/1.0"
    
    # Create conda-meta directory so kernel is discovered
    mkdir -p "$kernel1_path/conda-meta"
    
    # Setup mock conda command (needed for script to start)
    setup_mock_conda_cmd
    
    # Create invalid manifest (corrupted JSON)
    echo "invalid json content { not valid" > "$kernel1_path/package_manifest.json"
    
    local output_path="$TEST_BASE/collated.json"
    local output
    output=$("$KERNEL_INDEXER" collate-by-kernels --kernel-root "$kernel_root" --output "$output_path" 2>&1)
    
    # Should handle invalid manifest gracefully - check for error message or skip count
    # The script outputs "ERROR: Invalid manifest file" and "Skipped: 1"
    if (echo "$output" | grep -q "ERROR: Invalid manifest file") || \
       (echo "$output" | grep -q "Skipped:"); then
        # Also verify the output file was created (even if empty/with 0 kernels)
        if [ -f "$output_path" ]; then
            return 0
        else
            echo "Output file was not created"
            return 1
        fi
    else
        echo "Invalid manifest output: $output"
        if [ -f "$output_path" ]; then
            echo "Output file exists: $(cat "$output_path" 2>/dev/null || echo 'file is invalid')"
        fi
        return 1
    fi
}

# ============================================================================
# Run tests
# ============================================================================

# Phase 1: Prerequisites and Help
run_test "indexer_help_display" test_indexer_help_display "Help command displays usage information"
run_test "indexer_no_command" test_indexer_no_command "No command shows help and exits with error"
run_test "indexer_invalid_command" test_indexer_invalid_command "Invalid command is rejected with error"

# Phase 2: Command Validation
run_test "indexer_index_missing_kernel_root" test_indexer_index_missing_kernel_root "Index command requires --kernel-root when config unavailable"
run_test "indexer_index_invalid_option" test_indexer_index_invalid_option "Index command rejects unknown options"
run_test "indexer_index_kernel_version_without_name" test_indexer_index_kernel_version_without_name "--kernel-version requires --kernel-name"

# Phase 3: Kernel Discovery
run_test "indexer_discover_kernels_missing_root" test_indexer_discover_kernels_missing_root "Discovery handles missing kernel root directory"
run_test "indexer_discover_kernels_empty_directory" test_indexer_discover_kernels_empty_directory "Discovery handles empty directory"
run_test "indexer_discover_kernels_invalid_structure" test_indexer_discover_kernels_invalid_structure "Discovery skips invalid kernel structures"

# Phase 4: Kernel Indexing
run_test "indexer_index_r_kernel_success" test_indexer_index_r_kernel_success "Successfully index R kernel and create manifest"
run_test "indexer_index_python_kernel_success" test_indexer_index_python_kernel_success "Successfully index Python kernel and create manifest"
run_test "indexer_index_r_kernel_missing_rscript" test_indexer_index_r_kernel_missing_rscript "Indexing fails when R/Rscript binaries missing"
run_test "indexer_index_filters_by_name" test_indexer_index_filters_by_name "Indexing filters by kernel name"
run_test "indexer_index_filters_by_version" test_indexer_index_filters_by_version "Indexing filters by kernel name and version"

# Phase 5: Collation
run_test "indexer_collate_kernels_success" test_indexer_collate_kernels_success "Successfully collate manifests by kernels"
run_test "indexer_collate_packages_success" test_indexer_collate_packages_success "Successfully collate manifests by packages"
run_test "indexer_collate_missing_manifests" test_indexer_collate_missing_manifests "Collation handles missing manifest files gracefully"
run_test "indexer_collate_both_outputs" test_indexer_collate_both_outputs "Collate command creates both output files"
run_test "indexer_collate_language_filter" test_indexer_collate_language_filter "Collation respects language filter"

# Phase 6: Error Handling
run_test "indexer_error_invalid_manifest_json" test_indexer_error_invalid_manifest_json "Collation handles invalid manifest JSON gracefully"

