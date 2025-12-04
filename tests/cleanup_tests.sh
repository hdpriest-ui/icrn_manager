#!/bin/bash

# Cleanup script for ICRN Manager test suite
# This script removes test artifacts and temporary files created during test execution

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test directories and files to clean
TEST_BASE="$SCRIPT_DIR/test_env"
TEST_LOG="$SCRIPT_DIR/test_results.log"

# Function to print colored output
print_status() {
    local status_type=$1
    local message=$2
    case $status_type in
        "INFO")
            echo -e "${BLUE}ℹ INFO${NC}: $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✓ SUCCESS${NC}: $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠ WARNING${NC}: $message"
            ;;
        "ERROR")
            echo -e "${RED}✗ ERROR${NC}: $message"
            ;;
    esac
}

# Parse command line arguments
CLEAN_LOG=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--log)
            CLEAN_LOG=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -l, --log      Also remove test_results.log file"
            echo "  -v, --verbose  Enable verbose output"
            echo "  -h, --help     Show this help message"
            echo ""
            echo "This script removes the test environment directory (test_env/)"
            echo "and optionally the test results log file."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

echo "=========================================="
echo "ICRN Manager Test Cleanup"
echo "=========================================="
echo ""

# Clean test environment directory
if [ -d "$TEST_BASE" ]; then
    print_status "INFO" "Removing test environment directory: $TEST_BASE"
    if [ "$VERBOSE" = true ]; then
        rm -rfv "$TEST_BASE"
    else
        rm -rf "$TEST_BASE"
    fi
    
    if [ $? -eq 0 ]; then
        print_status "SUCCESS" "Test environment directory removed"
    else
        print_status "ERROR" "Failed to remove test environment directory"
        exit 1
    fi
else
    print_status "INFO" "Test environment directory does not exist: $TEST_BASE"
fi

# Clean test log file if requested
if [ "$CLEAN_LOG" = true ]; then
    if [ -f "$TEST_LOG" ]; then
        print_status "INFO" "Removing test results log: $TEST_LOG"
        rm -f "$TEST_LOG"
        
        if [ $? -eq 0 ]; then
            print_status "SUCCESS" "Test results log removed"
        else
            print_status "ERROR" "Failed to remove test results log"
            exit 1
        fi
    else
        print_status "INFO" "Test results log does not exist: $TEST_LOG"
    fi
else
    if [ -f "$TEST_LOG" ]; then
        print_status "INFO" "Test results log preserved: $TEST_LOG"
        print_status "INFO" "Use -l or --log to remove it"
    fi
fi

echo ""
print_status "SUCCESS" "Cleanup complete!"
echo ""

