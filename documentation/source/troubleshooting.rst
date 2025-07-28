Troubleshooting
==============

This section covers common issues and their solutions when using the ICRN Kernel Manager.

Common Issues
-------------

**Permission Errors**
~~~~~~~~~~~~~~~~~~~~~
If you encounter permission errors when using kernels:

.. code-block:: bash

   ERROR: no write permission for target directory: /path/to/directory
   ERROR: no write permission for target file: /path/to/file

**Solution:**
- Ensure you have write permissions to the target directory and file
- Check file ownership and permissions: `ls -la /path/to/file`
- Use `chmod` to adjust permissions if needed

**Invalid File Path Errors**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
If you see errors about invalid file paths:

.. code-block:: bash

   ERROR: target directory does not exist: /nonexistent/directory
   ERROR: no target Renviron file specified.

**Solution:**
- Verify the file path exists and is accessible
- Check that the directory structure is correct
- Ensure the path doesn't contain special characters that need escaping

**Configuration Errors**
~~~~~~~~~~~~~~~~~~~~~~~~
If commands fail with configuration errors:

.. code-block:: bash

   You must run "icrn_manager kernels init" prior to leveraging this tool.
   Couldn't locate user catalog at: /path/to/catalog

**Solution:**
- Run `./icrn_manager kernels init <repository_path>` to initialize the environment
- Verify the central repository path is correct and accessible
- Check that the catalog files exist and are readable

**Kernel Not Found Errors**
~~~~~~~~~~~~~~~~~~~~~~~~~~~
If a kernel cannot be found:

.. code-block:: bash

   ERROR: could not find target kernel to get
   Could not find version: 1.0

**Solution:**
- Use `./icrn_manager kernels available` to see available kernels
- Check the kernel name and version spelling
- Verify the kernel exists in the central catalog

**R Environment Issues**
~~~~~~~~~~~~~~~~~~~~~~~~
If R kernels don't work as expected:

.. code-block:: bash

   R_LIBS not set correctly
   Package not found in R

**Solution:**
- Use `./icrn_manager kernels use R <kernel> <version>` to activate the kernel
- Check that the kernel was properly installed with `./icrn_manager kernels list`
- Restart your R session after switching kernels
- Verify the .Renviron file contains the correct R_LIBS path

Error Handling Improvements
--------------------------
Recent updates to the ICRN Kernel Manager include improved error handling:

**File Path Validation**
- The system now validates file paths before attempting operations
- Clear error messages indicate exactly what went wrong
- Permission checks prevent silent failures

**Graceful Failures**
- Commands fail with descriptive error messages instead of shell errors
- Exit codes are consistent and meaningful
- Error output is formatted for easy reading

**Test Suite Validation**
- A comprehensive test suite validates all functionality
- Tests run in isolated environments to prevent interference
- Automated testing catches issues before they reach users

Debugging
---------
To debug issues with the ICRN Kernel Manager:

**Enable Verbose Output**
.. code-block:: bash

   # Run commands with additional output
   bash -x ./icrn_manager kernels list

**Check Configuration Files**
.. code-block:: bash

   # View current configuration
   cat ~/.icrn/manager_config.json
   cat ~/.icrn/icrn_kernels/user_catalog.json

**Verify File Permissions**
.. code-block:: bash

   # Check permissions on key directories
   ls -la ~/.icrn/
   ls -la ~/.icrn/icrn_kernels/

**Test Individual Components**
.. code-block:: bash

   # Test the update_r_libs script directly
   ./update_r_libs.sh ~/.Renviron test_kernel

Getting Help
-----------
If you continue to experience issues:

1. **Check the logs**: Look for error messages in the command output
2. **Run the test suite**: Use `./tests/run_tests.sh all` to verify your installation
3. **Review configuration**: Ensure all paths and permissions are correct
4. **Report issues**: Create an issue on GitHub with detailed error information

For more detailed information, see the :doc:`user_guide` and :doc:`maintainer_guide`. 