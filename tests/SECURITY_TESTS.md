# Security Tests for ICRN Manager

This document describes the comprehensive security tests added to protect against malicious use and careless use scenarios in the ICRN Manager kernel removal functionality.

## Overview

The security tests cover two main categories:
1. **Malicious Use Tests** - Attempts to exploit vulnerabilities
2. **Careless Use Tests** - Common user mistakes that could cause issues

## Malicious Use Tests

### 1. Wildcard Attack Tests
- **Test**: `test_kernels_remove_wildcard_attack`
- **Attack Vector**: Using `*` in kernel name or version
- **Example**: `icrn_manager kernels remove R "malicious*" "1.0"`
- **Expected**: Rejection with "Invalid characters" error
- **Protection**: Regex validation prevents shell glob expansion

### 2. Path Traversal Attack Tests
- **Test**: `test_kernels_remove_path_traversal_attack`
- **Attack Vector**: Using `../` in version to escape directory
- **Example**: `icrn_manager kernels remove R "kernel" "../../../etc"`
- **Expected**: Rejection with "Invalid characters" error
- **Protection**: Path separator validation prevents directory traversal

### 3. Bracket Expansion Attack Tests
- **Test**: `test_kernels_remove_bracket_expansion_attack`
- **Attack Vector**: Using `[` and `]` for shell bracket expansion
- **Example**: `icrn_manager kernels remove R "kernel[1]" "1.0"`
- **Expected**: Rejection with "Invalid characters" error
- **Protection**: Bracket validation prevents shell expansion

### 4. Question Mark Wildcard Attack Tests
- **Test**: `test_kernels_remove_question_mark_attack`
- **Attack Vector**: Using `?` for single character wildcard
- **Example**: `icrn_manager kernels remove R "kernel?" "1.0"`
- **Expected**: Rejection with "Invalid characters" error
- **Protection**: Question mark validation prevents shell expansion

### 5. Backslash Escape Attack Tests
- **Test**: `test_kernels_remove_backslash_attack`
- **Attack Vector**: Using `\` for escape sequences
- **Example**: `icrn_manager kernels remove R "kernel\\" "1.0"`
- **Expected**: Rejection with "Invalid characters" error
- **Protection**: Backslash validation prevents escape sequences

### 6. Symlink Attack Tests
- **Test**: `test_kernels_remove_symlink_attack`
- **Attack Vector**: Creating malicious symlinks pointing outside intended directory
- **Example**: Symlink from `kernel-dir` to `/tmp`
- **Expected**: Either "Could not locate" or "Security violation" error
- **Protection**: Path validation and realpath resolution

### 7. Get Command Attack Tests
- **Tests**: `test_kernels_get_wildcard_attack`, `test_kernels_get_path_traversal_attack`
- **Attack Vector**: Same attacks applied to `kernels get` command
- **Protection**: Same validation applied to both remove and get operations

## Careless Use Tests

### 1. Spaces in Names
- **Test**: `test_kernels_remove_careless_spaces`
- **Scenario**: User accidentally includes spaces in kernel name
- **Example**: `icrn_manager kernels remove R "kernel name" "1.0"`
- **Expected**: Usage error due to parameter parsing
- **Protection**: Proper parameter handling

### 2. Empty Parameters
- **Test**: `test_kernels_remove_careless_empty_params`
- **Scenario**: User provides empty string for kernel name
- **Example**: `icrn_manager kernels remove R "" "1.0"`
- **Expected**: Usage error or validation failure
- **Protection**: Parameter validation

### 3. Special Characters (Non-Malicious)
- **Test**: `test_kernels_remove_careless_special_chars`
- **Scenario**: User uses hyphens or other valid special characters
- **Example**: `icrn_manager kernels remove R "kernel-name" "1.0"`
- **Expected**: Normal operation (should be allowed)
- **Protection**: Only blocks truly dangerous characters

## Security Features Tested

### 1. Input Validation
- Regex pattern matching for dangerous characters
- Clear error messages for rejected inputs
- Consistent validation across all commands

### 2. Path Safety
- Directory boundary validation
- Symlink resolution and validation
- Path prefix checking

### 3. Shell Safety
- Proper variable quoting
- Prevention of glob expansion
- Prevention of command injection

### 4. Error Handling
- Graceful failure modes
- Informative error messages
- Safe exit codes

## Test Execution

To run all security tests:

```bash
cd tests
./run_tests.sh
```

To run only security tests:

```bash
cd tests
source test_common.sh
source test_kernels.sh

# Run individual security tests
test_kernels_remove_wildcard_attack
test_kernels_remove_path_traversal_attack
# ... etc
```

## Expected Test Results

All malicious use tests should **FAIL** (reject the attack) and all careless use tests should either **FAIL** gracefully or **PASS** safely. The successful cleanup test should **PASS** when the environment is properly set up.

## Security Principles Implemented

1. **Defense in Depth**: Multiple layers of validation
2. **Fail Secure**: Default to rejection when in doubt
3. **Principle of Least Privilege**: Only allow necessary operations
4. **Input Validation**: Validate all user inputs
5. **Path Safety**: Ensure operations stay within intended boundaries
6. **Clear Error Messages**: Help users understand what went wrong

## Future Enhancements

Consider adding tests for:
- Unicode normalization attacks
- Very long path names
- Race condition attacks
- Memory exhaustion attacks
- Symbolic link race conditions 