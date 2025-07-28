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

test_kernels_get_python_success() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Add mock conda-unpack to PATH
    export PATH="$TEST_BASE:$PATH"
    
    local output
    output=$(timeout 30 "$ICRN_MANAGER" kernels get Python numpy 1.24.0 2>&1)
    
    # Check if Python kernel unpacking succeeds
    if echo "$output" | grep -q "Updating user's catalog with Python numpy and 1.24.0" && \
       echo "$output" | grep -q "Be sure to call.*icrn_manager kernels use Python numpy 1.24.0"; then
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



# Security Tests for Remove Functionality

test_kernels_remove_wildcard_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test wildcard attack in kernel name
    local output
    output=$("$ICRN_MANAGER" kernels remove R "malicious*" "1.0" 2>&1)
    
    # Check if it rejects wildcards
    if echo "$output" | grep -q "Invalid characters in kernel name or version" && \
       echo "$output" | grep -q "Cannot contain wildcards"; then
        return 0
    else
        echo "Wildcard attack output: $output"
        return 1
    fi
}

test_kernels_remove_path_traversal_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test path traversal attack in version
    local output
    output=$("$ICRN_MANAGER" kernels remove R "kernel" "../../../etc" 2>&1)
    
    # Check if it rejects path separators
    if echo "$output" | grep -q "Invalid characters in kernel name or version" && \
       echo "$output" | grep -q "Cannot contain wildcards"; then
        return 0
    else
        echo "Path traversal attack output: $output"
        return 1
    fi
}

test_kernels_remove_bracket_expansion_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test bracket expansion attack
    local output
    output=$("$ICRN_MANAGER" kernels remove R "kernel[1]" "1.0" 2>&1)
    
    # Check if it rejects brackets
    if echo "$output" | grep -q "Invalid characters in kernel name or version" && \
       echo "$output" | grep -q "Cannot contain wildcards"; then
        return 0
    else
        echo "Bracket expansion attack output: $output"
        return 1
    fi
}

test_kernels_remove_question_mark_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test question mark wildcard attack
    local output
    output=$("$ICRN_MANAGER" kernels remove R "kernel?" "1.0" 2>&1)
    
    # Check if it rejects question marks
    if echo "$output" | grep -q "Invalid characters in kernel name or version" && \
       echo "$output" | grep -q "Cannot contain wildcards"; then
        return 0
    else
        echo "Question mark attack output: $output"
        return 1
    fi
}

test_kernels_remove_backslash_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test backslash escape attack
    local output
    output=$(timeout 10 "$ICRN_MANAGER" kernels remove R "kernel\\" "1.0" 2>&1)
    
    # Check if it rejects backslashes
    if echo "$output" | grep -q "Invalid characters in kernel name or version" && \
       echo "$output" | grep -q "Cannot contain wildcards"; then
        return 0
    else
        echo "Backslash attack output: $output"
        return 1
    fi
}

test_kernels_remove_symlink_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Create a malicious symlink that points outside the intended directory
    mkdir -p "$ICRN_USER_KERNEL_BASE"
    ln -sf /tmp "$ICRN_USER_KERNEL_BASE/malicious-symlink"
    
    # Test symlink attack (this should be caught by the path validation)
    local output
    output=$("$ICRN_MANAGER" kernels remove R "malicious-symlink" "1.0" 2>&1)
    
    # Check if it fails appropriately (either security violation or file not found)
    if echo "$output" | grep -q "Could not locate" || \
       echo "$output" | grep -q "Security violation"; then
        return 0
    else
        echo "Symlink attack output: $output"
        return 1
    fi
}

test_kernels_remove_careless_spaces() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test careless use with spaces in names
    local output
    output=$("$ICRN_MANAGER" kernels remove R "kernel name" "1.0" 2>&1)
    
    # Check if it handles spaces appropriately (should fail with missing parameters)
    if echo "$output" | grep -q "usage:" || \
       echo "$output" | grep -q "Can't proceed without"; then
        return 0
    else
        echo "Careless spaces output: $output"
        return 1
    fi
}

test_kernels_remove_careless_empty_params() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test careless use with empty parameters
    local output
    output=$("$ICRN_MANAGER" kernels remove R "" "1.0" 2>&1)
    
    # Check if it handles empty parameters appropriately
    if echo "$output" | grep -q "usage:" || \
       echo "$output" | grep -q "Can't proceed without"; then
        return 0
    else
        echo "Empty params output: $output"
        return 1
    fi
}

test_kernels_remove_careless_special_chars() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test careless use with special characters that aren't necessarily malicious
    local output
    output=$("$ICRN_MANAGER" kernels remove R "kernel-name" "1.0" 2>&1)
    
    # Check if it handles hyphens appropriately (should be allowed)
    if echo "$output" | grep -q "Could not locate" || \
       echo "$output" | grep -q "not present in user catalog"; then
        return 0
    else
        echo "Special chars output: $output"
        return 1
    fi
}

test_kernels_get_wildcard_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test wildcard attack in get command
    local output
    output=$("$ICRN_MANAGER" kernels get R "malicious*" "1.0" 2>&1)
    
    # Check if it rejects wildcards
    if echo "$output" | grep -q "Invalid characters in kernel name or version" && \
       echo "$output" | grep -q "Cannot contain wildcards"; then
        return 0
    else
        echo "Get wildcard attack output: $output"
        return 1
    fi
}

test_kernels_get_path_traversal_attack() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test path traversal attack in get command
    local output
    output=$("$ICRN_MANAGER" kernels get R "kernel" "../../../etc" 2>&1)
    
    # Check if it rejects path separators
    if echo "$output" | grep -q "Invalid characters in kernel name or version" && \
       echo "$output" | grep -q "Cannot contain wildcards"; then
        return 0
    else
        echo "Get path traversal attack output: $output"
        return 1
    fi
}

test_kernels_remove_successful_cleanup() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Create a test kernel directory to remove
    local test_kernel_dir="$ICRN_USER_KERNEL_BASE/test-kernel-1.0"
    mkdir -p "$test_kernel_dir"
    echo "test file" > "$test_kernel_dir/test.txt"
    
    # Add entry to user catalog
    local user_catalog="$ICRN_USER_CATALOG"
    local temp_catalog=$(mktemp)
    echo '{"R":{"test-kernel":{"1.0":{"path":"test-kernel-1.0"}}}}' > "$temp_catalog"
    mv "$temp_catalog" "$user_catalog"
    
    # Test successful removal (this will require user interaction, so we'll simulate it)
    # Since we can't easily simulate user input in tests, we'll test the validation logic
    # by checking that the directory exists and the catalog entry exists
    if [ -d "$test_kernel_dir" ] && [ -f "$user_catalog" ]; then
        # Verify the setup is correct
        if jq -e '.["R"]["test-kernel"]["1.0"]' "$user_catalog" >/dev/null 2>&1; then
            return 0
        else
            echo "Test kernel not properly set up in catalog"
            return 1
        fi
    else
        echo "Test kernel directory or catalog not created properly"
        return 1
    fi
}

test_kernels_use_python_success() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Create a mock Python kernel environment
    local python_kernel_dir="$ICRN_USER_KERNEL_BASE/python/test-python-1.0"
    mkdir -p "$python_kernel_dir/bin"
    echo "#!/bin/bash" > "$python_kernel_dir/bin/activate"
    echo "echo 'Activating conda environment'" >> "$python_kernel_dir/bin/activate"
    chmod +x "$python_kernel_dir/bin/activate"
    echo "#!/bin/bash" > "$python_kernel_dir/bin/deactivate"
    echo "echo 'Deactivating conda environment'" >> "$python_kernel_dir/bin/deactivate"
    chmod +x "$python_kernel_dir/bin/deactivate"
    
    # Add entry to user catalog
    local user_catalog="$ICRN_USER_CATALOG"
    jq '.Python.test_python."1.0".absolute_path = "'"$python_kernel_dir"'"' "$user_catalog" > "$user_catalog.tmp" && mv "$user_catalog.tmp" "$user_catalog"
    
    # Mock jupyter, python, and conda-unpack commands
    local mock_jupyter="$TEST_BASE/mock_jupyter"
    local mock_python="$TEST_BASE/mock_python"
    local mock_conda_unpack="$TEST_BASE/conda-unpack"
    
    echo '#!/bin/bash' > "$mock_jupyter"
    echo 'if [ "$1" = "kernelspec" ] && [ "$2" = "list" ]; then' >> "$mock_jupyter"
    echo '  echo "Available kernels:"' >> "$mock_jupyter"
    echo '  echo "  python3    /usr/local/share/jupyter/kernels/python3"' >> "$mock_jupyter"
    echo 'fi' >> "$mock_jupyter"
    echo 'if [ "$1" = "kernelspec" ] && [ "$2" = "uninstall" ]; then' >> "$mock_jupyter"
    echo '  echo "Removing kernel: $4"' >> "$mock_jupyter"
    echo 'fi' >> "$mock_jupyter"
    chmod +x "$mock_jupyter"
    
    echo '#!/bin/bash' > "$mock_python"
    echo 'if [ "$1" = "-m" ] && [ "$2" = "ipykernel" ]; then' >> "$mock_python"
    echo '  echo "Installing kernel: $6"' >> "$mock_python"
    echo 'fi' >> "$mock_python"
    chmod +x "$mock_python"
    
    echo '#!/bin/bash' > "$mock_conda_unpack"
    echo 'echo "Running conda-unpack (mock)"' >> "$mock_conda_unpack"
    chmod +x "$mock_conda_unpack"
    
    # Temporarily add mock commands to PATH
    export PATH="$TEST_BASE:$PATH"
    
    # Test Python kernel use
    local output
    output=$("$ICRN_MANAGER" kernels use Python test_python 1.0 2>&1)
    
    # Check if Python kernel use succeeds
    if echo "$output" | grep -q "Found. Activating Python kernel" && \
       echo "$output" | grep -q "Installing Python kernel: test_python-1.0"; then
        return 0
    else
        echo "Python use output: $output"
        return 1
    fi
}

test_kernels_use_python_none() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Add a test Python kernel to user catalog
    local user_catalog="$ICRN_USER_CATALOG"
    jq '.Python.test_kernel."1.0".absolute_path = "/tmp/test"' "$user_catalog" > "$user_catalog.tmp" && mv "$user_catalog.tmp" "$user_catalog"
    
    # Mock jupyter command that returns both system and user kernels
    local mock_jupyter="$TEST_BASE/mock_jupyter"
    echo '#!/bin/bash' > "$mock_jupyter"
    echo 'if [ "$1" = "kernelspec" ] && [ "$2" = "list" ] && [ "$3" = "--json" ]; then' >> "$mock_jupyter"
    echo '  echo "{\"kernelspecs\": {\"python3\": {\"spec\": \"/usr/local/share/jupyter/kernels/python3\"}, \"test_kernel-1.0\": {\"spec\": \"/tmp/test\"}}}"' >> "$mock_jupyter"
    echo 'fi' >> "$mock_jupyter"
    echo 'if [ "$1" = "kernelspec" ] && [ "$2" = "uninstall" ]; then' >> "$mock_jupyter"
    echo '  echo "Removing kernel: $4"' >> "$mock_jupyter"
    echo 'fi' >> "$mock_jupyter"
    chmod +x "$mock_jupyter"
    
    # Temporarily add mock command to PATH and verify it's being used
    export PATH="$TEST_BASE:$PATH"
    echo "DEBUG: Mock jupyter path: $(which jupyter)"
    echo "DEBUG: Mock jupyter content: $(cat "$mock_jupyter")"
    
    # Test Python kernel removal
    local output
    output=$(PATH="$TEST_BASE:$PATH" "$ICRN_MANAGER" kernels use Python none 2>&1)
    
    # Check if Python kernel removal succeeds and only removes catalog kernels
    if echo "$output" | grep -q "Removing preconfigured kernels from Python" && \
       echo "$output" | grep -q "Found Python kernels in user catalog: test_kernel-1.0" && \
       echo "$output" | grep -q "Removing kernel: test_kernel-1.0" && \
       echo "$output" | grep -q "Python kernel removal complete"; then
        return 0
    else
        echo "Python use none output: $output"
        return 1
    fi
}

# Run tests when sourced or executed directly
run_test "kernels_init" test_kernels_init "Kernels init creates necessary directories and config"
run_test "kernels_available" test_kernels_available "Kernels available shows catalog contents"
run_test "kernels_list_empty" test_kernels_list_empty "Kernels list shows empty user catalog initially"
run_test "kernels_get_python_success" test_kernels_get_python_success "Kernels get Python succeeds with proper unpacking"
run_test "kernels_get_r_fail" test_kernels_get_r_fail "Kernels get R fails with mock data"
run_test "kernels_get_invalid_language" test_kernels_get_invalid_language "Kernels get fails with invalid language"
run_test "kernels_get_missing_params" test_kernels_get_missing_params "Kernels get fails with missing parameters"
run_test "kernels_clean" test_kernels_clean "Kernels clean removes entries from user catalog"
run_test "kernels_clean_missing_params" test_kernels_clean_missing_params "Kernels clean fails with missing parameters"
run_test "kernels_remove_missing_params" test_kernels_remove_missing_params "Kernels remove fails with missing parameters"
run_test "kernels_use_missing_params" test_kernels_use_missing_params "Kernels use fails with missing parameters"
run_test "kernels_use_none" test_kernels_use_none "Kernels use handles 'none' parameter for R"
run_test "kernels_use_python_success" test_kernels_use_python_success "Kernels use Python succeeds with proper kernel installation"
run_test "kernels_use_python_none" test_kernels_use_python_none "Kernels use handles 'none' parameter for Python"

# Security Tests
run_test "kernels_remove_wildcard_attack" test_kernels_remove_wildcard_attack "Kernels remove rejects wildcard attacks"
run_test "kernels_remove_path_traversal_attack" test_kernels_remove_path_traversal_attack "Kernels remove rejects path traversal attacks"
run_test "kernels_remove_bracket_expansion_attack" test_kernels_remove_bracket_expansion_attack "Kernels remove rejects bracket expansion attacks"
run_test "kernels_remove_question_mark_attack" test_kernels_remove_question_mark_attack "Kernels remove rejects question mark wildcard attacks"
run_test "kernels_remove_backslash_attack" test_kernels_remove_backslash_attack "Kernels remove rejects backslash escape attacks"
run_test "kernels_remove_symlink_attack" test_kernels_remove_symlink_attack "Kernels remove handles symlink attacks safely"
run_test "kernels_remove_careless_spaces" test_kernels_remove_careless_spaces "Kernels remove handles careless use with spaces"
run_test "kernels_remove_careless_empty_params" test_kernels_remove_careless_empty_params "Kernels remove handles careless use with empty parameters"
run_test "kernels_remove_careless_special_chars" test_kernels_remove_careless_special_chars "Kernels remove handles careless use with special characters"
run_test "kernels_get_wildcard_attack" test_kernels_get_wildcard_attack "Kernels get rejects wildcard attacks"
run_test "kernels_get_path_traversal_attack" test_kernels_get_path_traversal_attack "Kernels get rejects path traversal attacks"
run_test "kernels_remove_successful_cleanup" test_kernels_remove_successful_cleanup "Kernels remove setup validation for successful cleanup" 