#!/bin/bash

# ICRN Manager Test Suite Runner
# This script runs all test suites for the ICRN Manager

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/test_common.sh"

# Parse command line arguments
VERBOSE=false
TEST_SUITES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] [TEST_SUITES...]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose    Enable verbose output"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Test Suites:"
            echo "  help             Test help commands and basic functionality"
            echo "  kernels          Test core kernel operations"
            echo "  update_r_libs    Test update_r_libs.sh functionality"
            echo "  config           Test configuration validation"
            echo "  all              Run all test suites (default)"
            echo ""
            echo "Examples:"
            echo "  $0                    # Run all tests"
            echo "  $0 kernels            # Run only kernel tests"
            echo "  $0 help config        # Run help and config tests"
            exit 0
            ;;
        *)
            TEST_SUITES+=("$1")
            shift
            ;;
    esac
done

# Default to all tests if none specified
if [ ${#TEST_SUITES[@]} -eq 0 ]; then
    TEST_SUITES=("all")
fi

# Function to run a test suite
run_test_suite() {
    local suite_name=$1
    local test_file=$2
    local description=$3
    
    echo ""
    echo "=========================================="
    echo "Running Test Suite: $suite_name"
    echo "Description: $description"
    echo "=========================================="
    
    if [ -f "$test_file" ] && [ -x "$test_file" ]; then
        # Source the test file to run its tests
        source "$test_file"
    else
        print_status "FAIL" "Test file $test_file not found or not executable"
        return 1
    fi
}

# Function to run all test suites
run_all_tests() {
    echo "=========================================="
    echo "ICRN Manager Test Suite"
    echo "=========================================="
    echo "Timestamp: $TIMESTAMP"
    echo "Project Root: $PROJECT_ROOT"
    echo "Test Base: $TEST_BASE"
    echo ""
    
    # Initialize test log
    echo "ICRN Manager Test Results - $TIMESTAMP" > "$TEST_LOG"
    echo "==========================================" >> "$TEST_LOG"
    
    # Check prerequisites
    if ! check_prerequisites; then
        print_status "FAIL" "Prerequisites check failed"
        exit 1
    fi
    
    # Run test suites
    echo ""
    echo "Running test suites..."
    echo "=========================================="
    
    # Run help and basic functionality tests
    run_test_suite "Help and Basic Commands" "$SCRIPT_DIR/test_help.sh" "Testing help commands and basic functionality"
    
    # Run kernel functionality tests
    run_test_suite "Kernel Operations" "$SCRIPT_DIR/test_kernels.sh" "Testing core kernel operations (init, available, list, get, clean, remove, use)"
    
    # Run update_r_libs tests
    run_test_suite "Update R Libs" "$SCRIPT_DIR/test_update_r_libs.sh" "Testing update_r_libs.sh functionality"
    
    # Run configuration tests
    run_test_suite "Configuration and Validation" "$SCRIPT_DIR/test_config.sh" "Testing configuration validation and error handling"
    
    # Print summary
    print_test_summary
}

# Function to run specific test suite
run_specific_suite() {
    local suite_name=$1
    
    echo "=========================================="
    echo "ICRN Manager Test Suite - $suite_name"
    echo "=========================================="
    echo "Timestamp: $TIMESTAMP"
    echo "Project Root: $PROJECT_ROOT"
    echo ""
    
    # Initialize test log
    echo "ICRN Manager Test Results - $suite_name - $TIMESTAMP" > "$TEST_LOG"
    echo "==========================================" >> "$TEST_LOG"
    
    # Check prerequisites
    if ! check_prerequisites; then
        print_status "FAIL" "Prerequisites check failed"
        exit 1
    fi
    
    # Run specific test suite
    case $suite_name in
        "help")
            run_test_suite "Help and Basic Commands" "$SCRIPT_DIR/test_help.sh" "Testing help commands and basic functionality"
            ;;
        "kernels")
            run_test_suite "Kernel Operations" "$SCRIPT_DIR/test_kernels.sh" "Testing core kernel operations"
            ;;
        "update_r_libs")
            run_test_suite "Update R Libs" "$SCRIPT_DIR/test_update_r_libs.sh" "Testing update_r_libs.sh functionality"
            ;;
        "config")
            run_test_suite "Configuration and Validation" "$SCRIPT_DIR/test_config.sh" "Testing configuration validation"
            ;;
        *)
            echo "Unknown test suite: $suite_name"
            echo "Available suites: help, kernels, update_r_libs, config"
            exit 1
            ;;
    esac
    
    # Print summary
    print_test_summary
}

# Main execution
if [ ${#TEST_SUITES[@]} -eq 1 ] && [ "${TEST_SUITES[0]}" = "all" ]; then
    run_all_tests
else
    for suite in "${TEST_SUITES[@]}"; do
        run_specific_suite "$suite"
    done
fi 