Contributing
============

We welcome contributions to the Illinois Computes Library & Kernel Manager project!

The source code and latest updates are available on GitHub: `hdpriest-ui/icrn_manager <https://github.com/hdpriest-ui/icrn_manager>`

Developer Guide: Creating New Kernels
-------------------------------------
- To contribute new R kernels (library environments) to the central catalog, see :doc:`maintainer_guide` for a step-by-step walkthrough using Bioconductor as an example.

Development Environment
-----------------------
The project includes a Docker development environment that mimics the NCSA ICRN JupyterHub environment:

- **Docker Setup**: See `.github/docker/Rstudio/Dockerfile` for the complete development environment
- **Automated Builds**: GitHub Actions automatically builds and pushes Docker images to the GitHub Container Registry
- **Dependencies**: The Docker image includes R, RStudio, jq, and all necessary tools for testing icrn_manager

To use the development environment:

.. code-block:: bash

   # Pull the latest image
   docker pull ghcr.io/hdpriest-ui/icrn_manager:latest
   
   # Run the container
   docker run -it ghcr.io/hdpriest-ui/icrn_manager:latest

The icrn_manager tools are automatically available in the container's PATH.

Testing
-------
The project includes a comprehensive test suite to ensure code quality and reliability. All tests are designed to run independently with isolated environments.

**Prerequisites:**
- `jq` - JSON processor for test data validation
- `tar` - For testing kernel packaging functionality
- `timeout` - For testing command timeouts (usually available on Linux systems)

**Running Tests:**

.. code-block:: bash

   # Run all test suites
   ./tests/run_tests.sh all
   
   # Run specific test suites
   ./tests/run_tests.sh kernels          # Kernel operations
   ./tests/run_tests.sh update_r_libs    # R library management
   ./tests/run_tests.sh config           # Configuration validation
   ./tests/run_tests.sh help             # Help and basic commands

**Test Structure:**
- **Test Isolation**: Each test runs in its own isolated environment to prevent interference
- **Mock Data**: Tests use mock kernel packages and catalogs for consistent testing
- **Error Handling**: Tests verify both success and failure scenarios
- **Comprehensive Coverage**: Tests cover all major functionality including edge cases

**Test Categories:**

1. **Kernel Operations** (`test_kernels.sh`)
   - Initialization and configuration
   - Listing available and installed kernels
   - Getting and using kernels
   - Cleaning and removing kernels
   - Error handling for invalid parameters

2. **R Library Management** (`test_update_r_libs.sh`)
   - Adding kernels to .Renviron files
   - Removing kernels from .Renviron files
   - Overwriting existing kernel configurations
   - File permission and path validation
   - Error handling for invalid file paths

3. **Configuration Validation** (`test_config.sh`)
   - Missing configuration file handling
   - Invalid catalog and repository validation
   - JSON structure validation
   - Required field validation

4. **Help and Basic Commands** (`test_help.sh`)
   - Help command functionality
   - Invalid command handling
   - Usage information display

**Test Environment:**
- Tests create isolated environments in `./tests/test_env/`
- Each test cleans up after itself
- Mock data includes sample R and Python kernels
- Environment variables are properly isolated per test

**Continuous Integration:**
- GitHub Actions automatically runs the full test suite on pull requests
- Tests run in the Docker development environment
- All tests must pass before merging

**Writing New Tests:**
When adding new functionality, please include corresponding tests:

.. code-block:: bash

   # Example test function structure
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

How to Contribute
-----------------
- Report bugs or request features via the issue tracker.
- Submit pull requests for code or documentation improvements.
- Propose enhancements to the documentation site.
- **Always run the test suite before submitting changes.**

Improving Documentation
----------------------
- Edit or add reStructuredText (.rst) files in the documentation/icrn_manager_docs/ directory.
- Follow Sphinx and Read the Docs best practices for structure and formatting.
- Preview your changes locally before submitting a pull request.

Code Contributions
------------------
- Fork the repository and create a feature branch.
- Follow the existing code style and add comments where helpful.
- **Test your changes thoroughly using the test suite.**
- Ensure all tests pass before submitting a pull request.
- The GitHub Actions workflow will automatically test your changes in the Docker environment.

Thank you for helping improve the Illinois Computes Library & Kernel Manager! 