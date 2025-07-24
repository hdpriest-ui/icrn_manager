#!/bin/bash

# Test file for configuration validation and error handling

source "$(dirname "$0")/test_common.sh"

test_config_validation_missing_config() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Remove any existing config
    rm -rf "$ICRN_USER_BASE"
    
    # Test that commands fail without config
    local output
    output=$("$ICRN_MANAGER" kernels list 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "You must run.*kernels init"; then
        return 0
    else
        echo "Missing config output: $output"
        return 1
    fi
}

test_config_validation_missing_catalog() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Remove the catalog file
    rm -f "$ICRN_KERNEL_CATALOG"
    
    # Test that commands fail without catalog
    local output
    output=$("$ICRN_MANAGER" kernels available 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "Couldn't locate.*central catalog" || \
       echo "$output" | grep -q "Please contact support"; then
        return 0
    else
        echo "Missing catalog output: $output"
        return 1
    fi
}

test_config_validation_missing_repository() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Remove the repository directory
    rm -rf "$TEST_REPO"
    
    # Test that commands fail without repository
    local output
    output=$("$ICRN_MANAGER" kernels available 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "Couldn't locate.*kernel repository" || \
       echo "$output" | grep -q "Please contact support"; then
        return 0
    else
        echo "Missing repository output: $output"
        return 1
    fi
}

test_config_validation_language_param() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test with invalid language parameter
    local output
    output=$("$ICRN_MANAGER" kernels get InvalidKernel 1.0 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "Unsupported language" || \
       echo "$output" | grep -q "ERROR: could not find target kernel"; then
        return 0
    else
        echo "Invalid language output: $output"
        return 1
    fi
}

test_config_validation_kernel_param() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test with non-existent kernel
    local output
    output=$("$ICRN_MANAGER" kernels get R NonExistentKernel 1.0 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "ERROR: could not find target kernel"; then
        return 0
    else
        echo "Invalid kernel output: $output"
        return 1
    fi
}

test_config_validation_version_param() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test with non-existent version
    local output
    output=$("$ICRN_MANAGER" kernels get R cowsay 999.0 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "ERROR: could not find target kernel" || \
       echo "$output" | grep -q "Could not find version"; then
        return 0
    else
        echo "Invalid version output: $output"
        return 1
    fi
}

test_config_json_structure() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test that config file has valid JSON structure
    if jq -e . "$ICRN_MANAGER_CONFIG" >/dev/null 2>&1; then
        return 0
    else
        echo "Config JSON structure validation failed"
        echo "Config content: $(cat "$ICRN_MANAGER_CONFIG" 2>/dev/null || echo 'file not found')"
        return 1
    fi
}

test_user_catalog_json_structure() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test that user catalog has valid JSON structure
    if jq -e . "$ICRN_USER_CATALOG" >/dev/null 2>&1; then
        return 0
    else
        echo "User catalog JSON structure validation failed"
        echo "User catalog content: $(cat "$ICRN_USER_CATALOG" 2>/dev/null || echo 'file not found')"
        return 1
    fi
}

test_catalog_json_structure() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test that central catalog has valid JSON structure
    if jq -e . "$ICRN_KERNEL_CATALOG" >/dev/null 2>&1; then
        return 0
    else
        echo "Catalog JSON structure validation failed"
        echo "Catalog content: $(cat "$ICRN_KERNEL_CATALOG" 2>/dev/null || echo 'file not found')"
        return 1
    fi
}

test_catalog_required_fields() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test that catalog has required fields for each kernel
    local has_required_fields=true
    
    # Check R kernels
    if ! jq -e '.R.cowsay."1.0"."conda-pack"' "$ICRN_KERNEL_CATALOG" >/dev/null 2>&1; then
        echo "Missing conda-pack field in R cowsay kernel"
        has_required_fields=false
    fi
    
    # Check Python kernels
    if ! jq -e '.Python.numpy."1.24.0"."conda-pack"' "$ICRN_KERNEL_CATALOG" >/dev/null 2>&1; then
        echo "Missing conda-pack field in Python numpy kernel"
        has_required_fields=false
    fi
    
    if [ "$has_required_fields" = true ]; then
        return 0
    else
        echo "Catalog missing required fields"
        echo "Catalog content: $(cat "$ICRN_KERNEL_CATALOG")"
        return 1
    fi
}

# Run tests when sourced or executed directly
run_test "config_validation_missing_config" test_config_validation_missing_config "Commands fail without config file"
run_test "config_validation_missing_catalog" test_config_validation_missing_catalog "Commands fail without central catalog"
run_test "config_validation_missing_repository" test_config_validation_missing_repository "Commands fail without repository"
run_test "config_validation_language_param" test_config_validation_language_param "Commands fail with invalid language parameter"
run_test "config_validation_kernel_param" test_config_validation_kernel_param "Commands fail with invalid kernel parameter"
run_test "config_validation_version_param" test_config_validation_version_param "Commands fail with invalid version parameter"
run_test "config_json_structure" test_config_json_structure "Config file has valid JSON structure"
run_test "user_catalog_json_structure" test_user_catalog_json_structure "User catalog has valid JSON structure"
run_test "catalog_json_structure" test_catalog_json_structure "Central catalog has valid JSON structure"
run_test "catalog_required_fields" test_catalog_required_fields "Catalog has required fields for all kernels" 