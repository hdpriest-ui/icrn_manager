# ICRN Manager Test Suite

This directory contains the comprehensive test suite for the ICRN Kernel Manager. The test suite ensures reliability, correctness, and security of all kernel management operations.

## Quick Start

```bash
# Run all tests (57 tests total)
./tests/run_tests.sh all

# Run specific test categories
./tests/run_tests.sh kernels          # Kernel operations (18 tests)
./tests/run_tests.sh update_r_libs    # R library management (6 tests)
./tests/run_tests.sh config           # Configuration validation (10 tests)
./tests/run_tests.sh help             # Help and basic commands (3 tests)
./tests/run_tests.sh kernel_indexer   # Kernel indexing (20 tests)

# Clean up test artifacts after running tests
./tests/cleanup_tests.sh

# Clean up including test results log
./tests/cleanup_tests.sh --log
```

## Test Suite Overview

The test suite consists of **57 tests** organized into 5 main categories:

| Category | Tests | Description |
|----------|-------|-------------|
| **Kernel Operations** | 18 | Core kernel management (init, get, use, clean, list, available) |
| **Kernel Indexer** | 20 | Kernel indexing, discovery, and manifest collation |
| **Configuration Validation** | 10 | Config file validation, error handling, JSON structure |
| **R Library Management** | 6 | update_r_libs.sh functionality and .Renviron management |
| **Help & Basic Commands** | 3 | Help commands, usage information, error messages |

## Test Structure

### Test Files

- **`test_common.sh`** - Common utilities, test framework, and helper functions
- **`test_kernels.sh`** - Kernel operations (init, get, use, clean, list, available)
- **`test_kernel_indexer.sh`** - Kernel indexing and manifest collation
- **`test_config.sh`** - Configuration validation and error handling
- **`test_update_r_libs.sh`** - R library management functionality
- **`test_help.sh`** - Help commands and basic functionality
- **`run_tests.sh`** - Test runner and orchestration script
- **`cleanup_tests.sh`** - Cleanup script for test artifacts

### Test Categories

#### 1. Kernel Operations (18 tests)

Tests core kernel management functionality:

- **Initialization**: `kernels init` creates necessary directories and config files
- **Discovery**: `kernels available` lists kernels from central catalog
- **Listing**: `kernels list` shows user's installed kernels
- **Getting Kernels**: `kernels get` downloads and registers kernels (R and Python)
- **Using Kernels**: `kernels use` activates kernels for use
- **Cleaning**: `kernels clean` removes kernel entries from user catalog
- **Error Handling**: Invalid parameters, missing arguments, invalid languages
- **Security**: Path traversal protection, wildcard attack prevention

**Key Features Tested:**
- Automatic initialization with confirmation prompts
- Overlay directory creation for R kernels
- Python kernel registration (in-place)
- R kernel registration with overlay paths
- Kernel activation and deactivation
- Catalog management

#### 2. Kernel Indexer (20 tests)

Tests the kernel indexing service:

- **Help & Commands**: Help display, invalid commands, missing commands
- **Indexing**: R and Python kernel indexing, manifest creation
- **Discovery**: Kernel discovery, empty directories, invalid structures
- **Filtering**: Filtering by kernel name and version
- **Collation**: Manifest collation by kernels and by packages
- **Error Handling**: Missing manifests, invalid JSON, missing R/Rscript

**Key Features Tested:**
- Kernel discovery in repository structure
- Package manifest generation
- Collated manifest creation (kernel-centric and package-centric)
- Language filtering
- Error recovery and graceful degradation

#### 3. Configuration Validation (10 tests)

Tests configuration file handling and validation:

- **Missing Config**: Auto-initialization when config is missing
- **Missing Catalog**: Error handling when central catalog is missing
- **Missing Repository**: Error handling when repository directory is missing
- **Parameter Validation**: Invalid language, kernel, and version parameters
- **JSON Structure**: Valid JSON structure for config, user catalog, and central catalog
- **Required Fields**: Catalog contains all required fields for kernels

**Key Features Tested:**
- Automatic initialization behavior
- Configuration file validation
- Catalog structure validation
- Error messages and user guidance

#### 4. R Library Management (6 tests)

Tests the `update_r_libs.sh` script:

- **Adding Kernels**: Adding kernel paths to .Renviron files
- **Removing Kernels**: Removing kernel configurations from .Renviron
- **Overwriting**: Updating existing kernel configurations
- **Preservation**: Preserving existing .Renviron content
- **Error Handling**: Missing parameters, invalid file paths

**Key Features Tested:**
- .Renviron file modification
- ICRN additions section management
- R_LIBS and R_LIBS_USER configuration
- Overlay path handling

#### 5. Help & Basic Commands (3 tests)

Tests basic command functionality:

- **Help Command**: Help text display and usage information
- **Invalid Commands**: Error handling for unknown commands
- **Kernels Help**: Help display for kernels subcommand

## Test Environment

### Isolation

Each test runs in a completely isolated environment:

- **Fresh Environment**: `setup_test_env` creates a new test environment for each test
- **Temporary Directories**: Tests use `./tests/test_env/` for all temporary files
- **No Shared State**: Tests don't interfere with each other
- **Automatic Cleanup**: Test environment is cleaned up after each test

### Mock Data

The test suite uses consistent mock data:

**R Kernels:**
- `cowsay` (version 1.0)
- `ggplot2` (version 3.4.0)

**Python Kernels:**
- `numpy` (version 1.24.0)

**Mock Catalog:**
- Valid JSON structure with proper kernel metadata
- Environment locations pointing to test repository
- Proper language organization (R and Python)

**Mock Kernel Environments:**
- In-place conda environments (not tar files)
- Proper directory structure with `bin/` directories
- Mock activation/deactivation scripts
- Mock Rscript binaries for R kernels

### Prerequisites

The test suite requires the following tools:

- **`jq`** - JSON processor for test data validation and manipulation
- **`tar`** - For testing kernel packaging functionality (if needed)
- **`timeout`** - For testing command timeouts (Linux systems)
- **`bash`** - Bash shell (version 4.0 or later)

Install missing dependencies:

```bash
# On Ubuntu/Debian
sudo apt-get install jq coreutils

# On RHEL/CentOS
sudo yum install jq coreutils

# On macOS
brew install jq coreutils
```

## Running Tests

### Basic Usage

```bash
# Run all tests
./tests/run_tests.sh all

# Run a specific test suite
./tests/run_tests.sh kernels

# Run multiple test suites
./tests/run_tests.sh help config

# Verbose output
./tests/run_tests.sh --verbose kernels
```

### Test Output

The test runner provides:
- **Colored Output**: Green for passes, red for failures
- **Test Descriptions**: Each test shows its purpose
- **Summary**: Total tests, passed, failed, skipped
- **Log File**: Detailed results saved to `test_results.log`

### Test Results

Test results are saved to `./tests/test_results.log` with timestamps and detailed information about each test execution.

## Cleanup

After running tests, clean up test artifacts:

```bash
# Remove test environment directory (keeps test_results.log)
./tests/cleanup_tests.sh

# Remove everything including test results log
./tests/cleanup_tests.sh --log

# Verbose cleanup output
./tests/cleanup_tests.sh --verbose

# Show help
./tests/cleanup_tests.sh --help
```

The cleanup script removes:
- `test_env/` directory (test environment)
- `test_results.log` (optional, with `--log` flag)

## Writing Tests

### Test Function Structure

All tests follow a consistent structure:

```bash
test_new_feature() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Initialize if needed (with automatic confirmation)
    echo "y" | "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1
    
    # Test the new functionality
    # Use icrn_manager_with_confirm for commands that auto-initialize
    local output
    output=$(icrn_manager_with_confirm kernels new_command 2>&1)
    
    # Verify expected behavior
    if echo "$output" | grep -q "expected output"; then
        return 0
    else
        echo "Test output: $output"
        return 1
    fi
}
```

### Handling Automatic Initialization

Since initialization now occurs automatically, tests must handle confirmation prompts:

```bash
# For explicit init calls
echo "y" | "$ICRN_MANAGER" kernels init "$TEST_REPO" >/dev/null 2>&1

# For commands that auto-initialize (use helper function)
output=$(icrn_manager_with_confirm kernels available 2>&1)

# For commands that need multiple confirmations (like clean)
output=$(echo -e "y\ny" | "$ICRN_MANAGER" kernels clean R kernel version 2>&1)

# For timeout/env contexts, pipe directly
output=$(echo "y" | timeout 30 "$ICRN_MANAGER" kernels get R cowsay 1.0 2>&1)
```

### Test Registration

Add your test to the appropriate test file and register it at the bottom:

```bash
# Run tests when sourced or executed directly
run_test "new_feature" test_new_feature "Description of what the test does"
```

### Best Practices

1. **Always use isolation**: Call `setup_test_env` and `set_test_env` at the start
2. **Handle auto-init**: Use `icrn_manager_with_confirm` or pipe "y" for commands that auto-initialize
3. **Test both paths**: Test both success and failure scenarios
4. **Descriptive names**: Use clear, descriptive test names and descriptions
5. **Check output**: Verify specific error messages, not just exit codes
6. **Clean up**: The test framework handles cleanup, but be aware of what you create
7. **Mock dependencies**: Use mock commands when testing external tool interactions
8. **Security testing**: Include security tests for path traversal, wildcards, etc.

### Helper Functions

The test framework provides several helper functions:

- **`setup_test_env`**: Creates a fresh test environment
- **`set_test_env`**: Sets environment variables for test isolation
- **`icrn_manager_with_confirm`**: Runs icrn_manager with automatic "y" confirmation
- **`print_status`**: Prints colored status messages
- **`run_test`**: Registers and runs a test
- **`skip_test`**: Skips a test with a reason

## Continuous Integration

The test suite is integrated into the CI/CD pipeline:

- **GitHub Actions**: Automatically runs on all pull requests
- **Docker Environment**: Tests run in containerized environment
- **Required Passing**: All tests must pass before merging
- **Test Logging**: Results are captured and reported

## Troubleshooting

### Common Issues

**Permission Errors**
```bash
# Ensure test directories are writable
chmod -R u+w ./tests/test_env/
```

**Missing Dependencies**
```bash
# Check if jq is installed
which jq

# Install missing tools
sudo apt-get install jq coreutils  # Ubuntu/Debian
```

**Test Failures**
- Check the test output for specific error messages
- Review `test_results.log` for detailed information
- Verify the test environment is properly isolated
- Ensure mock data is correctly set up

**Environment Issues**
```bash
# Check test environment
ls -la ./tests/test_env/

# View test logs
cat ./tests/test_results.log

# Run with verbose output
bash -x ./tests/run_tests.sh kernels
```

### Debugging Tests

```bash
# Run a single test suite with verbose output
./tests/run_tests.sh --verbose kernels

# Run with bash debugging
bash -x ./tests/run_tests.sh kernels

# Inspect test environment after a test
# (modify test to not cleanup, or pause before cleanup)
ls -la ./tests/test_env/user_home/.icrn/

# Check test output directly
./tests/run_tests.sh kernels 2>&1 | tee test_output.log
```

## Security Testing

The test suite includes comprehensive security tests:

- **Path Traversal Protection**: Tests reject `../` in kernel names and versions
- **Wildcard Attack Prevention**: Tests reject wildcards (`*`, `?`) in parameters
- **Input Validation**: Tests validate all user inputs for dangerous characters
- **File System Safety**: Tests ensure operations stay within expected directories

See `SECURITY_TESTS.md` for detailed security test documentation.

## Test Statistics

Current test coverage:
- **Total Tests**: 57
- **Test Categories**: 5
- **Test Files**: 6
- **Average Tests per Category**: ~11

## Additional Resources

- **Main README**: [../README.md](../README.md) - Project overview and usage
- **Contributing Guide**: [../documentation/source/contributing.rst](../documentation/source/contributing.rst) - Contribution guidelines
- **Security Tests**: [SECURITY_TESTS.md](SECURITY_TESTS.md) - Security testing documentation

## Questions or Issues?

If you encounter issues with the test suite:
1. Check the troubleshooting section above
2. Review the test output and logs
3. Verify all prerequisites are installed
4. Check the main project documentation
5. Open an issue on the project repository
