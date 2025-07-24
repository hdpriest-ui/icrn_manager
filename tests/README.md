# ICRN Manager Test Suite

This directory contains the comprehensive test suite for the ICRN Kernel Manager.

## Quick Start

```bash
# Run all tests
./tests/run_tests.sh all

# Run specific test categories
./tests/run_tests.sh kernels          # Kernel operations
./tests/run_tests.sh update_r_libs    # R library management
./tests/run_tests.sh config           # Configuration validation
./tests/run_tests.sh help             # Help and basic commands
```

## Test Structure

### Test Files
- `test_common.sh` - Common utilities and test framework
- `test_kernels.sh` - Kernel operations (init, get, use, clean, etc.)
- `test_update_r_libs.sh` - R library management functionality
- `test_config.sh` - Configuration validation and error handling
- `test_help.sh` - Help commands and basic functionality
- `run_tests.sh` - Test runner and orchestration

### Test Categories

#### Kernel Operations (13 tests)
- Initialization and configuration
- Listing available and installed kernels
- Getting and using kernels
- Cleaning and removing kernels
- Error handling for invalid parameters

#### R Library Management (6 tests)
- Adding kernels to .Renviron files
- Removing kernels from .Renviron files
- Overwriting existing kernel configurations
- File permission and path validation
- Error handling for invalid file paths

#### Configuration Validation (10 tests)
- Missing configuration file handling
- Invalid catalog and repository validation
- JSON structure validation
- Required field validation

#### Help and Basic Commands (3 tests)
- Help command functionality
- Invalid command handling
- Usage information display

## Test Environment

### Isolation
- Each test runs in its own isolated environment
- Tests create temporary directories in `./tests/test_env/`
- No shared state between tests
- Automatic cleanup after each test

### Mock Data
- Sample R kernels: `cowsay` (1.0), `ggplot2` (3.4.0)
- Sample Python kernel: `numpy` (1.24.0)
- Mock catalog with proper JSON structure
- Valid tar files for testing kernel extraction

### Prerequisites
- `jq` - JSON processor for test data validation
- `tar` - For testing kernel packaging functionality
- `timeout` - For testing command timeouts (Linux systems)

## Writing Tests

### Test Function Structure
```bash
test_new_feature() {
    # Setup fresh test environment for this test
    setup_test_env
    set_test_env
    
    # Test the new functionality
    local output
    output=$("$ICRN_MANAGER" new_command 2>&1)
    
    # Verify expected behavior
    if echo "$output" | grep -q "expected output"; then
        return 0
    else
        echo "Test output: $output"
        return 1
    fi
}
```

### Test Registration
Add your test to the appropriate test file and register it:

```bash
# Run tests when sourced or executed directly
run_test "new_feature" test_new_feature "Description of what the test does"
```

### Best Practices
- Always use `setup_test_env` and `set_test_env` for isolation
- Test both success and failure scenarios
- Use descriptive test names and descriptions
- Check for specific error messages, not just exit codes
- Clean up any files created during testing

## Continuous Integration

- GitHub Actions automatically runs the full test suite on pull requests
- Tests run in the Docker development environment
- All tests must pass before merging
- Test results are logged to `./tests/test_results.log`

## Troubleshooting

### Common Issues
- **Permission errors**: Ensure test directories are writable
- **Missing dependencies**: Install `jq`, `tar`, and `timeout`
- **Test failures**: Check the test output for specific error messages
- **Environment issues**: Verify the test environment is properly isolated

### Debugging
```bash
# Run with verbose output
bash -x ./tests/run_tests.sh kernels

# Check test environment
ls -la ./tests/test_env/

# View test logs
cat ./tests/test_results.log
```

For more detailed information, see the [Contributing Guide](../documentation/source/contributing.rst). 