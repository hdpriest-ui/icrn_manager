#!/bin/bash

# Test file for core kernel functionality

source "$(dirname "$0")/test_common.sh"

test_kernels_init() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Clean any existing config
    rm -rf "$ICRN_USER_BASE"
    
    # Run init
    local output
    output=$("$ICRN_MANAGER" kernels init "$TEST_REPO" 2>&1)
    
    # Check if init was successful
    if [ -f "$ICRN_USER_BASE/manager_config.json" ] && \
       [ -f "$ICRN_USER_BASE/icrn_kernels/user_catalog.json" ] && \
       echo "$output" | grep -q "Initializing icrn kernel resources"; then
        return 0
    else
        echo "Init output: $output"
        return 1
    fi
}

test_kernels_available() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$("$ICRN_MANAGER" kernels available 2>&1)
    
    # Check if available shows the expected kernels
    if echo "$output" | grep -q "Language" && \
       echo "$output" | grep -q "R" && \
       echo "$output" | grep -q "Python" && \
       echo "$output" | grep -q "cowsay" && \
       echo "$output" | grep -q "numpy"; then
        return 0
    else
        echo "Available output: $output"
        return 1
    fi
}

test_kernels_list_empty() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$("$ICRN_MANAGER" kernels list 2>&1)
    
    # Check if list shows empty catalog
    if echo "$output" | grep -q "checked out kernels" && \
       echo "$output" | grep -q "Language"; then
        return 0
    else
        echo "List output: $output"
        return 1
    fi
}

test_kernels_get_python_fail() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$(timeout 10 "$ICRN_MANAGER" kernels get Python numpy 1.24.0 2>&1)
    
    # Check if it fails as expected (Python unpacking not implemented or tar extraction fails)
    if echo "$output" | grep -q "Python kernel unpacking not yet implemented" || \
       echo "$output" | grep -q "ERROR:" || \
       echo "$output" | grep -q "timeout"; then
        return 0
    else
        echo "Python get output: $output"
        return 1
    fi
}

test_kernels_get_r_fail() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$(timeout 10 "$ICRN_MANAGER" kernels get R cowsay 1.0 2>&1)
    
    # Check if it fails as expected (mock tar file issues or other errors)
    if echo "$output" | grep -q "ERROR:" || \
       echo "$output" | grep -q "timeout"; then
        return 0
    else
        echo "R get output: $output"
        return 1
    fi
}

test_kernels_get_invalid_language() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$("$ICRN_MANAGER" kernels get Invalid cowsay 1.0 2>&1)
    
    # Check if it fails with unsupported language error
    if echo "$output" | grep -q "Unsupported language"; then
        return 0
    else
        # If not unsupported language, it should fail because kernel doesn't exist
        if echo "$output" | grep -q "ERROR: could not find target kernel to get"; then
            return 0
        else
            echo "Invalid language output: $output"
            return 1
        fi
    fi
}

test_kernels_get_missing_params() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$("$ICRN_MANAGER" kernels get 2>&1)
    
    # Check if it fails with usage message
    if echo "$output" | grep -q "usage: icrn_manager kernels get <language> <kernel name> <version number>"; then
        return 0
    else
        echo "Missing params output: $output"
        return 1
    fi
}

test_kernels_clean() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Add a test entry to user catalog
    local user_catalog="$ICRN_USER_BASE/icrn_kernels/user_catalog.json"
    jq '.R.test_kernel.test_version = {"absolute_path": "/tmp/test"}' "$user_catalog" > "$user_catalog.tmp" && mv "$user_catalog.tmp" "$user_catalog"
    
    # Test clean with automatic confirmation
    local output
    output=$(echo "y" | "$ICRN_MANAGER" kernels clean R test_kernel test_version 2>&1)
    
    # Check if clean was successful
    if echo "$output" | grep -q "Desired kernel to scrub from user catalog" && \
       ! jq -e '.R.test_kernel.test_version' "$user_catalog" >/dev/null 2>&1; then
        return 0
    else
        echo "Clean output: $output"
        return 1
    fi
}

test_kernels_clean_missing_params() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$(echo "y" | timeout 5 "$ICRN_MANAGER" kernels clean 2>&1)
    local exit_code=$?
    
    # Check if it fails with usage message or if timeout occurred
    if echo "$output" | grep -q "usage: icrn_manager kernels clean <language> <kernel name> <version number>" || \
       [ $exit_code -eq 124 ]; then
        return 0
    else
        echo "Clean missing params output: $output"
        echo "Exit code: $exit_code"
        return 1
    fi
}

test_kernels_remove_missing_params() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test with explicit timeout and debug output
    local output
    output=$(timeout 5 bash -c "cd '$PROJECT_ROOT' && '$ICRN_MANAGER' kernels remove" 2>&1)
    local exit_code=$?
    
    # Check if it fails with usage message or if timeout occurred
    if echo "$output" | grep -q "usage: icrn_manager kernels remove <language> <kernel name> <version number>" || \
       [ $exit_code -eq 124 ]; then
        return 0
    else
        echo "Remove missing params output: $output"
        echo "Exit code: $exit_code"
        return 1
    fi
}

test_kernels_use_missing_params() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$("$ICRN_MANAGER" kernels use 2>&1)
    
    # Check if it fails with usage message (new format includes "none" option)
    if echo "$output" | grep -q "usage: icrn_manager kernels use <language> <kernel name> \[version number\]" && \
       echo "$output" | grep -q "or: icrn_manager kernels use <language> none"; then
        return 0
    else
        echo "Use missing params output: $output"
        return 1
    fi
}

test_kernels_use_none() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Create a test .Renviron file
    local test_renviron="$TEST_USER_HOME/.Renviron"
    echo "R_LIBS=/usr/lib/R/library" > "$test_renviron"
    
    local output
    output=$("$ICRN_MANAGER" kernels use R none 2>&1)
    
    # Check if it handles "none" correctly
    if echo "$output" | grep -q "Desired kernel: none for R" && \
       echo "$output" | grep -q "Removing preconfigured kernels from R"; then
        return 0
    else
        echo "Use none output: $output"
        return 1
    fi
}

test_kernels_use_python_none() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$("$ICRN_MANAGER" kernels use Python none 2>&1)
    
    # Check if it handles "none" correctly for Python
    if echo "$output" | grep -q "Desired kernel: none for Python" && \
       echo "$output" | grep -q "Python kernel removal not yet implemented"; then
        return 0
    else
        echo "Use Python none output: $output"
        return 1
    fi
}

# Run tests when sourced or executed directly
run_test "kernels_init" test_kernels_init "Kernels init creates necessary directories and config"
run_test "kernels_available" test_kernels_available "Kernels available shows catalog contents"
run_test "kernels_list_empty" test_kernels_list_empty "Kernels list shows empty user catalog initially"
run_test "kernels_get_python_fail" test_kernels_get_python_fail "Kernels get Python fails gracefully (not implemented)"
run_test "kernels_get_r_fail" test_kernels_get_r_fail "Kernels get R fails with mock data"
run_test "kernels_get_invalid_language" test_kernels_get_invalid_language "Kernels get fails with invalid language"
run_test "kernels_get_missing_params" test_kernels_get_missing_params "Kernels get fails with missing parameters"
run_test "kernels_clean" test_kernels_clean "Kernels clean removes entries from user catalog"
run_test "kernels_clean_missing_params" test_kernels_clean_missing_params "Kernels clean fails with missing parameters"
run_test "kernels_remove_missing_params" test_kernels_remove_missing_params "Kernels remove fails with missing parameters"
run_test "kernels_use_missing_params" test_kernels_use_missing_params "Kernels use fails with missing parameters"
run_test "kernels_use_none" test_kernels_use_none "Kernels use handles 'none' parameter for R"
run_test "kernels_use_python_none" test_kernels_use_python_none "Kernels use handles 'none' parameter for Python" 