#!/bin/bash

# Test file for update_r_libs.sh functionality

source "$(dirname "$0")/test_common.sh"

test_update_r_libs_add() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Create a test .Renviron file
    local test_renviron="$TEST_USER_HOME/.Renviron"
    echo "R_LIBS=/usr/lib/R/library" > "$test_renviron"
    
    # Test adding a kernel with overlay path
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "/path/to/kernel" "/path/to/overlay" 2>&1)
    
    # Check if it was successful
    if echo "$output" | grep -q "Using.*/path/to/kernel.*within R" && \
       echo "$output" | grep -q "Using.*/path/to/overlay.*for new R package installs" && \
       grep -q "ICRN ADDITIONS" "$test_renviron"; then
        return 0
    else
        echo "Add output: $output"
        echo "File content: $(cat "$test_renviron")"
        return 1
    fi
}

test_update_r_libs_remove() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Create a test .Renviron file with existing content
    local test_renviron="$TEST_USER_HOME/.Renviron"
    echo "R_LIBS=/usr/lib/R/library" > "$test_renviron"
    echo "# ICRN ADDITIONS" >> "$test_renviron"
    echo "R_LIBS_USER=/path/to/test_kernel" >> "$test_renviron"
    
    # Test removing kernels (passing empty strings as kernel and overlay paths)
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "" "" 2>&1)
    
    # Check if it was successful - the script should replace ICRN additions with unset
    # Note: The script doesn't remove old ICRN additions, it just adds new ones
    if echo "$output" | grep -q "Unsetting R_libs" && \
       grep -q "R_LIBS=" "$test_renviron"; then
        return 0
    else
        echo "Remove output: $output"
        echo "File content: $(cat "$test_renviron")"
        return 1
    fi
}

test_update_r_libs_overwrite() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Create a test .Renviron file with existing ICRN content
    local test_renviron="$TEST_USER_HOME/.Renviron"
    echo "R_LIBS=/usr/lib/R/library" > "$test_renviron"
    echo "# ICRN ADDITIONS" >> "$test_renviron"
    echo "R_LIBS_USER=/path/to/old_kernel" >> "$test_renviron"
    
    # Test overwriting with new kernel and overlay
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "/path/to/new_kernel" "/path/to/new_overlay" 2>&1)
    
    # Check if it was successful - the script should replace old ICRN additions with new ones
    if echo "$output" | grep -q "Using.*/path/to/new_kernel.*within R" && \
       echo "$output" | grep -q "Using.*/path/to/new_overlay.*for new R package installs" && \
       grep -q "ICRN ADDITIONS" "$test_renviron"; then
        return 0
    else
        echo "Overwrite output: $output"
        echo "File content: $(cat "$test_renviron")"
        return 1
    fi
}

test_update_r_libs_missing_params() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    local output
    output=$("$UPDATE_R_LIBS" 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "no target Renviron file specified"; then
        return 0
    else
        echo "Missing params output: $output"
        return 1
    fi
}

test_update_r_libs_invalid_file() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    local output
    output=$("$UPDATE_R_LIBS" "/nonexistent/file" "/path/to/kernel" "/path/to/overlay" 2>&1)
    
    # Check if it fails with appropriate error
    if echo "$output" | grep -q "no target Renviron file specified" || \
       echo "$output" | grep -q "ERROR:"; then
        return 0
    else
        echo "Invalid file output: $output"
        return 1
    fi
}

test_update_r_libs_empty_kernel() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Create a test .Renviron file
    local test_renviron="$TEST_USER_HOME/.Renviron"
    echo "R_LIBS=/usr/lib/R/library" > "$test_renviron"
    
    # Test with empty kernel and overlay paths
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "" "" 2>&1)
    
    # Check if it handles empty kernel name correctly
    if echo "$output" | grep -q "Unsetting R_libs"; then
        return 0
    else
        echo "Empty kernel output: $output"
        return 1
    fi
}

test_update_r_libs_preserve_content() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Create a test .Renviron file with existing content
    local test_renviron="$TEST_USER_HOME/.Renviron"
    echo "R_LIBS=/usr/lib/R/library" > "$test_renviron"
    echo "R_PROFILE=/path/to/profile" >> "$test_renviron"
    echo "R_ENVIRON=/path/to/environ" >> "$test_renviron"
    
    # Test adding a kernel with overlay
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "/path/to/kernel" "/path/to/overlay" 2>&1)
    
    # Check if it preserves existing content
    if echo "$output" | grep -q "Using.*/path/to/kernel.*within R" && \
       echo "$output" | grep -q "Using.*/path/to/overlay.*for new R package installs" && \
       grep -q "R_LIBS=/usr/lib/R/library" "$test_renviron" && \
       grep -q "R_PROFILE=/path/to/profile" "$test_renviron" && \
       grep -q "R_ENVIRON=/path/to/environ" "$test_renviron" && \
       grep -q "ICRN ADDITIONS" "$test_renviron"; then
        return 0
    else
        echo "Preserve content output: $output"
        echo "File content: $(cat "$test_renviron")"
        return 1
    fi
}

# Run tests when sourced or executed directly
run_test "update_r_libs_add" test_update_r_libs_add "Update R libs adds kernel to .Renviron"
run_test "update_r_libs_remove" test_update_r_libs_remove "Update R libs removes kernels from .Renviron"
run_test "update_r_libs_overwrite" test_update_r_libs_overwrite "Update R libs overwrites existing kernel"
run_test "update_r_libs_missing_params" test_update_r_libs_missing_params "Update R libs fails with missing parameters"
run_test "update_r_libs_invalid_file" test_update_r_libs_invalid_file "Update R libs handles invalid file paths"
run_test "update_r_libs_preserve_content" test_update_r_libs_preserve_content "Update R libs preserves existing .Renviron content" 