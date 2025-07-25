#!/bin/bash

# Common test utilities for ICRN Manager tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ICRN_MANAGER="$PROJECT_ROOT/icrn_manager"
UPDATE_R_LIBS="$PROJECT_ROOT/update_r_libs.sh"

# Test directories
TEST_BASE="$SCRIPT_DIR/test_env"
TEST_REPO="$TEST_BASE/repository"
TEST_USER_HOME="$TEST_BASE/user_home"

# Test counters (shared across test files)
if [ -z "$TOTAL_TESTS" ]; then
    TOTAL_TESTS=0
    PASSED_TESTS=0
    FAILED_TESTS=0
    SKIPPED_TESTS=0
    FAILED_TEST_NAMES=()
fi

# Test results log
TEST_LOG="$SCRIPT_DIR/test_results.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to print colored output
print_status() {
    local status_type=$1
    local message=$2
    case $status_type in
        "PASS")
            echo -e "${GREEN}✓ PASS${NC}: $message"
            ;;
        "FAIL")
            echo -e "${RED}✗ FAIL${NC}: $message"
            ;;
        "SKIP")
            echo -e "${YELLOW}⚠ SKIP${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ INFO${NC}: $message"
            ;;
    esac
}

# Function to log test results
log_test() {
    local test_name=$1
    local status=$2
    local message=$3
    echo "[$TIMESTAMP] $status: $test_name - $message" >> "$TEST_LOG"
}

# Function to run a test
run_test() {
    local test_name=$1
    local test_function=$2
    local description=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo ""
    echo "Running test: $test_name"
    echo "Description: $description"
    echo "----------------------------------------"
    
    # Run the test function
    if $test_function; then
        print_status "PASS" "$test_name: $description"
        log_test "$test_name" "PASS" "$description"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        print_status "FAIL" "$test_name: $description"
        log_test "$test_name" "FAIL" "$description"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TEST_NAMES+=("$test_name")
        return 1
    fi
}

# Function to skip a test
skip_test() {
    local test_name=$1
    local reason=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    
    print_status "SKIP" "$test_name: $reason"
    log_test "$test_name" "SKIP" "$reason"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "INFO" "Checking prerequisites..."
    
    # Check if icrn_manager exists and is executable
    if [ ! -f "$ICRN_MANAGER" ]; then
        print_status "FAIL" "icrn_manager script not found at $ICRN_MANAGER"
        return 1
    fi
    
    if [ ! -x "$ICRN_MANAGER" ]; then
        print_status "FAIL" "icrn_manager script is not executable"
        return 1
    fi
    
    # Check if update_r_libs.sh exists and is executable
    if [ ! -f "$UPDATE_R_LIBS" ]; then
        print_status "FAIL" "update_r_libs.sh script not found at $UPDATE_R_LIBS"
        return 1
    fi
    
    if [ ! -x "$UPDATE_R_LIBS" ]; then
        print_status "FAIL" "update_r_libs.sh script is not executable"
        return 1
    fi
    
    # Check for required tools
    if ! command -v jq &> /dev/null; then
        print_status "FAIL" "jq is required but not installed"
        return 1
    fi
    
    if ! command -v tar &> /dev/null; then
        print_status "FAIL" "tar is required but not installed"
        return 1
    fi
    
    print_status "PASS" "All prerequisites met"
    return 0
}

# Function to setup test environment
setup_test_env() {
    print_status "INFO" "Setting up test environment..."
    
    # Clean up any existing test environment
    if [ -d "$TEST_BASE" ]; then
        rm -rf "$TEST_BASE"
    fi
    
    # Create test directories
    mkdir -p "$TEST_BASE"
    mkdir -p "$TEST_REPO"
    mkdir -p "$TEST_USER_HOME"
    
    # Create mock repository structure
    mkdir -p "$TEST_REPO/r_kernels"
    mkdir -p "$TEST_REPO/python_kernels"
    
    # Create mock catalog
    cat > "$TEST_REPO/icrn_kernel_catalog.json" << 'EOF'
{
  "R": {
    "cowsay": {
      "1.0": {
        "conda-pack": "cowsay-1.0.tar.gz",
        "description": "Test R kernel for cowsay package"
      }
    },
    "ggplot2": {
      "3.4.0": {
        "conda-pack": "ggplot2-3.4.0.tar.gz",
        "description": "Test R kernel for ggplot2 package"
      }
    }
  },
  "Python": {
    "numpy": {
      "1.24.0": {
        "conda-pack": "numpy-1.24.0.tar.gz",
        "description": "Test Python kernel for numpy package"
      }
    }
  }
}
EOF
    
    # Create mock kernel packages (valid tar files for testing)
    mkdir -p "$TEST_REPO/r_kernels/cowsay/1.0"
    mkdir -p "$TEST_REPO/r_kernels/ggplot2/3.4.0"
    mkdir -p "$TEST_REPO/python_kernels/numpy/1.24.0"
    
    # Create valid tar files with dummy content for testing
    echo "dummy content" > "$TEST_REPO/r_kernels/cowsay/1.0/dummy.txt"
    tar -czf "$TEST_REPO/r_kernels/cowsay/1.0/cowsay-1.0.tar.gz" -C "$TEST_REPO/r_kernels/cowsay/1.0" dummy.txt 2>/dev/null || true
    
    echo "dummy content" > "$TEST_REPO/r_kernels/ggplot2/3.4.0/dummy.txt"
    tar -czf "$TEST_REPO/r_kernels/ggplot2/3.4.0/ggplot2-3.4.0.tar.gz" -C "$TEST_REPO/r_kernels/ggplot2/3.4.0" dummy.txt 2>/dev/null || true
    
    # Create Python kernel mock with conda environment structure
    mkdir -p "$TEST_REPO/python_kernels/numpy/1.24.0/bin"
    echo "dummy content" > "$TEST_REPO/python_kernels/numpy/1.24.0/dummy.txt"
    echo "#!/bin/bash" > "$TEST_REPO/python_kernels/numpy/1.24.0/bin/activate"
    echo "echo 'Activating conda environment'" >> "$TEST_REPO/python_kernels/numpy/1.24.0/bin/activate"
    chmod +x "$TEST_REPO/python_kernels/numpy/1.24.0/bin/activate"
    echo "#!/bin/bash" > "$TEST_REPO/python_kernels/numpy/1.24.0/bin/deactivate"
    echo "echo 'Deactivating conda environment'" >> "$TEST_REPO/python_kernels/numpy/1.24.0/bin/deactivate"
    chmod +x "$TEST_REPO/python_kernels/numpy/1.24.0/bin/deactivate"
    tar -czf "$TEST_REPO/python_kernels/numpy/1.24.0/numpy-1.24.0.tar.gz" -C "$TEST_REPO/python_kernels/numpy/1.24.0" . 2>/dev/null || true
    
    # Create mock conda-unpack command
    echo '#!/bin/bash' > "$TEST_BASE/conda-unpack"
    echo 'echo "Running conda-unpack (mock)"' >> "$TEST_BASE/conda-unpack"
    chmod +x "$TEST_BASE/conda-unpack"
    
    print_status "PASS" "Test environment setup complete"
}

# Function to cleanup test environment
cleanup_test_env() {
    print_status "INFO" "Cleaning up test environment..."
    
    if [ -d "$TEST_BASE" ]; then
        rm -rf "$TEST_BASE"
    fi
    
    print_status "PASS" "Test environment cleanup complete"
}

# Function to set test environment variables
set_test_env() {
    export HOME="$TEST_USER_HOME"
    export ICRN_USER_BASE="$TEST_USER_HOME/.icrn"
    export ICRN_USER_KERNEL_BASE="$TEST_USER_HOME/.icrn/icrn_kernels"
    export ICRN_USER_CATALOG="$TEST_USER_HOME/.icrn/icrn_kernels/user_catalog.json"
}

# Function to print test summary
print_test_summary() {
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Skipped: $SKIPPED_TESTS"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        print_status "PASS" "All tests passed!"
        echo "Test log saved to: $TEST_LOG"
        return 0
    else
        print_status "FAIL" "$FAILED_TESTS test(s) failed"
        echo ""
        echo "Failed Tests:"
        for test_name in "${FAILED_TEST_NAMES[@]}"; do
            echo "  - $test_name"
        done
        echo ""
        echo "Test log saved to: $TEST_LOG"
        return 1
    fi
} 