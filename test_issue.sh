#!/bin/bash

# Minimal test to demonstrate the hanging issue
# This test calls 'kernels remove' without parameters, which should fail with a usage message
# but instead hangs at the confirm prompt

echo "Testing kernels remove without parameters..."
echo "This should fail with a usage message, not hang."

# Set up minimal environment
export HOME="/tmp/test_home"
export ICRN_USER_BASE="$HOME/.icrn"
export ICRN_MANAGER_CONFIG="$ICRN_USER_BASE/manager_config.json"
export ICRN_USER_KERNEL_BASE="$ICRN_USER_BASE/icrn_kernels"
export ICRN_USER_CATALOG="$ICRN_USER_KERNEL_BASE/user_catalog.json"

# Create minimal config
mkdir -p "$ICRN_USER_BASE"
mkdir -p "$ICRN_USER_KERNEL_BASE"
echo "{}" > "$ICRN_USER_CATALOG"
echo '{
  "icrn_central_catalog_path": "/tmp/test_repo",
  "icrn_r_kernels": "r_kernels",
  "icrn_python_kernels": "python_kernels",
  "icrn_kernel_catalog": "icrn_kernel_catalog.json"
}' > "$ICRN_MANAGER_CONFIG"

# Create minimal catalog
mkdir -p "/tmp/test_repo"
echo '{"R":{}}' > "/tmp/test_repo/icrn_kernel_catalog.json"

# Test the command that hangs
echo "Running: ./icrn_manager kernels remove"
timeout 10 ./icrn_manager kernels remove

echo "Test completed." 