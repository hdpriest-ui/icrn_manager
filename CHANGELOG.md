# Changelog

All notable changes to the ICRN Kernel Manager project will be documented in this file.

## [Unreleased] - 2024-07-24

### Added
- **Kernel Indexer**: New `kernel_indexer` script for indexing kernels and generating package manifests
  - Indexes R and Python kernels and extracts package information
  - Generates JSON manifest files for each kernel with package metadata
  - Collates manifests into kernel-centric and package-centric indexes
  - Supports filtering by language, kernel name, and version
  - Extracts packages from both conda and language-specific package managers
- **Comprehensive Test Suite**: Added a complete test suite with 52+ tests covering all major functionality
  - `test_kernel_indexer.sh`: 20 tests covering kernel indexing and collation
- **Test Isolation**: Each test now runs in its own isolated environment to prevent interference
- **Mock Data**: Tests use consistent mock kernel packages and catalogs for reliable testing
- **Error Handling Tests**: Added tests for both success and failure scenarios

### Improved
- **Error Handling**: Enhanced error messages throughout the codebase with clear, descriptive output
- **File Path Validation**: Added comprehensive validation for file paths and permissions
- **update_r_libs.sh**: Improved error handling for invalid file paths and missing directories
- **Test Reliability**: Tests now clean up after themselves and don't share state

### Fixed
- **Test Interference**: Resolved issues where tests could affect each other's results
- **Ungraceful Failures**: Fixed cases where commands would fail with shell errors instead of clear messages
- **Permission Issues**: Added proper permission checking before file operations
- **Configuration Validation**: Improved validation of configuration files and directories

### Technical Details
- **Test Structure**: 
  - `test_kernels.sh`: 13 tests covering kernel operations
  - `test_update_r_libs.sh`: 6 tests covering R library management
  - `test_config.sh`: 10 tests covering configuration validation
  - `test_help.sh`: 3 tests covering help and basic commands
  - `test_kernel_indexer.sh`: 20 tests covering kernel indexing and collation
- **Test Environment**: Isolated environments created in `./tests/test_env/`
- **Mock Data**: Sample R and Python kernels with proper catalog structure
- **Mock Commands**: Tests include mock conda, Rscript, and python commands for isolated testing
- **Error Messages**: Standardized error message format with "ERROR:" prefix

### Documentation
- **Contributing Guide**: Added comprehensive testing section with examples, including kernel_indexer test suite
- **Maintainer Guide**: Added kernel indexing documentation for R and Python kernels
- **Reference Documentation**: Added complete kernel_indexer command reference
- **Troubleshooting**: Updated with improved error handling information
- **README**: Added testing section with command examples, including kernel_indexer tests

## [Previous Releases]

*Note: This changelog was started with the recent test suite and error handling improvements. Previous releases may not be documented here.* 