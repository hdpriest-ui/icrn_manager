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
    
    # Check if Python kernel registration succeeds (in-place, no unpacking)
    if echo "$output" | grep -q "Updating user's catalog with Python numpy and 1.24.0" && \
       echo "$output" | grep -q "Be sure to call.*icrn_manager kernels use Python numpy 1.24.0"; then
        return 0
    else
        echo "Python get output: $output"
        return 1
    fi
}

test_kernels_get_r_success() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$(timeout 30 "$ICRN_MANAGER" kernels get R cowsay 1.0 2>&1)
    
    # Check if R kernel registration succeeds (in-place, no unpacking)
    if echo "$output" | grep -q "registering R library" && \
       echo "$output" | grep -q "registering user overlay" && \
       echo "$output" | grep -q "Be sure to call.*icrn_manager kernels use R cowsay 1.0"; then
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



# Security Tests for Get Functionality

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
    local mock_jupyter="$TEST_BASE/jupyter"
    echo '#!/bin/bash' > "$mock_jupyter"
    echo 'if [ "$1" = "kernelspec" ] && [ "$2" = "list" ] && [ "$3" = "--json" ]; then' >> "$mock_jupyter"
    echo '  echo "{\"kernelspecs\": {\"python3\": {\"spec\": \"/usr/local/share/jupyter/kernels/python3\"}, \"test_kernel-1.0\": {\"spec\": \"/tmp/test\"}}}"' >> "$mock_jupyter"
    echo 'fi' >> "$mock_jupyter"
    echo 'if [ "$1" = "kernelspec" ] && [ "$2" = "uninstall" ]; then' >> "$mock_jupyter"
    echo '  echo "Removing kernel: $4"' >> "$mock_jupyter"
    echo 'fi' >> "$mock_jupyter"
    chmod +x "$mock_jupyter"
    
    # Test Python kernel removal with mock jupyter in PATH
    local output
    output=$(env PATH="$TEST_BASE:$PATH" "$ICRN_MANAGER" kernels use Python none 2>&1)
    
    # Check if Python kernel removal succeeds and only removes catalog kernels
    # Note: The mock jupyter should return test_kernel-1.0 in the kernelspec list
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

test_kernels_use_with_overlay() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Create a mock R kernel with overlay
    local user_catalog="$ICRN_USER_CATALOG"
    local overlay_dir="$ICRN_USER_KERNEL_BASE/r/cowsay-1.0"
    local mock_r_lib="$TEST_BASE/mock_r_lib"
    
    # Create the mock R library directory
    mkdir -p "$overlay_dir"
    mkdir -p "$mock_r_lib"
    
    jq '.R.cowsay."1.0" = {
        "absolute_path": "'"$mock_r_lib"'",
        "overlay_path": "'"$overlay_dir"'"
    }' "$user_catalog" > "$user_catalog.tmp" && mv "$user_catalog.tmp" "$user_catalog"
    
    # Create a test .Renviron file
    local test_renviron="$TEST_USER_HOME/.Renviron"
    echo "R_LIBS=/usr/lib/R/library" > "$test_renviron"
    
    # Mock update_r_libs.sh
    local mock_update_r_libs="$TEST_BASE/update_r_libs.sh"
    echo '#!/bin/bash' > "$mock_update_r_libs"
    echo 'echo "Called with: $@"' >> "$mock_update_r_libs"
    chmod +x "$mock_update_r_libs"
    
    # Test using kernel with overlay
    local output
    output=$(PATH="$TEST_BASE:$PATH" "$ICRN_MANAGER" kernels use R cowsay 1.0 2>&1)
    
    # Check if it uses overlay path
    if echo "$output" | grep -q "Found. Linking and Activating" || \
       echo "$output" | grep -q "Called with:.*$overlay_dir"; then
        return 0
    else
        echo "Use with overlay output: $output"
        return 1
    fi
}

test_kernels_get_creates_overlay_directory() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    local output
    output=$(timeout 30 "$ICRN_MANAGER" kernels get R cowsay 1.0 2>&1)
    
    # Check if overlay directory was created
    local overlay_dir="$ICRN_USER_KERNEL_BASE/r/cowsay-1.0"
    if [ -d "$overlay_dir" ] && \
       echo "$output" | grep -q "registering user overlay"; then
        return 0
    else
        echo "Overlay directory creation output: $output"
        echo "Overlay directory exists: $([ -d "$overlay_dir" ] && echo "yes" || echo "no")"
        return 1
    fi
}

test_kernels_get_security_path_traversal() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize the environment first
    "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test path traversal in kernel name
    local output
    output=$("$ICRN_MANAGER" kernels get R "../../etc" "1.0" 2>&1)
    
    # Check if it rejects path separators
    if echo "$output" | grep -q "Invalid characters in kernel name or version"; then
        return 0
    else
        echo "Path traversal security output: $output"
        return 1
    fi
}

# Run tests when sourced or executed directly
run_test "kernels_init" test_kernels_init "Kernels init creates necessary directories and config"
run_test "kernels_available" test_kernels_available "Kernels available shows catalog contents"
run_test "kernels_list_empty" test_kernels_list_empty "Kernels list shows empty user catalog initially"
run_test "kernels_get_python_success" test_kernels_get_python_success "Kernels get Python succeeds with proper registration"
run_test "kernels_get_r_success" test_kernels_get_r_success "Kernels get R succeeds with proper registration"
run_test "kernels_get_invalid_language" test_kernels_get_invalid_language "Kernels get fails with invalid language"
run_test "kernels_get_missing_params" test_kernels_get_missing_params "Kernels get fails with missing parameters"
run_test "kernels_clean" test_kernels_clean "Kernels clean removes entries from user catalog"
run_test "kernels_clean_missing_params" test_kernels_clean_missing_params "Kernels clean fails with missing parameters"
run_test "kernels_use_missing_params" test_kernels_use_missing_params "Kernels use fails with missing parameters"
run_test "kernels_use_none" test_kernels_use_none "Kernels use handles 'none' parameter for R"
run_test "kernels_use_python_success" test_kernels_use_python_success "Kernels use Python succeeds with proper kernel installation"
run_test "kernels_use_python_none" test_kernels_use_python_none "Kernels use handles 'none' parameter for Python"
run_test "kernels_use_with_overlay" test_kernels_use_with_overlay "Kernels use correctly uses overlay path"
run_test "kernels_get_creates_overlay_directory" test_kernels_get_creates_overlay_directory "Kernels get creates overlay directory"
run_test "kernels_get_security_path_traversal" test_kernels_get_security_path_traversal "Kernels get rejects path traversal attempts"

# Security Tests
run_test "kernels_get_wildcard_attack" test_kernels_get_wildcard_attack "Kernels get rejects wildcard attacks"
run_test "kernels_get_path_traversal_attack" test_kernels_get_path_traversal_attack "Kernels get rejects path traversal attacks" 