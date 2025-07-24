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
    
    # Test adding a kernel
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "test_kernel" 2>&1)
    
    # Check if it was successful
    if echo "$output" | grep -q "Using.*test_kernel.*within R" && \
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
    
    # Test removing kernels
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" 2>&1)
    
    # Check if it was successful
    if echo "$output" | grep -q "Removing preconfigured kernels from R" && \
       ! grep -q "ICRN ADDITIONS" "$test_renviron"; then
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
    
    # Test overwriting with new kernel
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "new_kernel" 2>&1)
    
    # Check if it was successful
    if echo "$output" | grep -q "Using.*new_kernel.*within R" && \
       grep -q "ICRN ADDITIONS" "$test_renviron" && \
       ! grep -q "old_kernel" "$test_renviron"; then
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
    if echo "$output" | grep -q "usage:" || \
       echo "$output" | grep -q "ERROR:"; then
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
    
    # Test with a valid path that should work
    local test_file="$TEST_BASE/test_invalid.Renviron"
    mkdir -p "$(dirname "$test_file")"
    
    local output
    output=$("$UPDATE_R_LIBS" "$test_file" "test_kernel" 2>&1)
    
    # Should work and create the file
    if echo "$output" | grep -q "Using.*test_kernel.*within R" && \
       [ -f "$test_file" ] && \
       grep -q "ICRN ADDITIONS" "$test_file"; then
        # Clean up
        rm -f "$test_file"
        return 0
    else
        echo "Invalid file output: $output"
        echo "File content: $(cat "$test_file" 2>/dev/null || echo 'file not found')"
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
    
    # Test adding a kernel
    local output
    output=$("$UPDATE_R_LIBS" "$test_renviron" "test_kernel" 2>&1)
    
    # Check if it preserves existing content
    if echo "$output" | grep -q "Using.*test_kernel.*within R" && \
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