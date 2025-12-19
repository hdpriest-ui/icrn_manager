RStudio Interface
=================

The ICRN Kernel Manager provides a graphical interface for RStudio users through an RStudio Addin. This interface allows you to browse, select, and activate R kernels without using the command line.

Typical Workflow
~~~~~~~~~~~~~~~~

1. Select a kernel from the dropdown
2. Click **Execute** next to "Get kernel" (first time only)
3. Click **Execute** next to "Use kernel"
4. **Restart your R session** (see below)

Accessing the Kernel Manager
----------------------------

To open the Kernel Manager in RStudio:

1. Click on the **Addins** menu in the RStudio toolbar
2. Select **Manage Kernels** from the dropdown

This opens a dialog window where you can browse and manage available R kernels.

Browsing Available Kernels
--------------------------

When the Kernel Manager opens:

1. A searchable dropdown displays all available R kernels
2. Kernels are listed in the format ``kernel_name-version`` (e.g., ``bioconductor-3.20``, ``tidyverse-4.4``)
3. Begin typing in the search box to filter kernels by name

For more detailed information about kernel contents and package lists, click the link to the **kernel information page** shown at the top of the dialog.

Selecting and Using a Kernel
----------------------------

Once you select a kernel from the dropdown, two commands are displayed:

**Get Kernel**
   Downloads the kernel to your local environment. Use this if you haven't previously downloaded the kernel.

   - Click **Copy** to copy the command to your clipboard
   - Click **Execute** to run the command directly

**Use Kernel**
   Activates the kernel for your R session. This updates your R library paths to use the selected kernel's packages.

   - Click **Copy** to copy the command to your clipboard
   - Click **Execute** to run the command directly


Restarting Your R Session
-------------------------

After switching kernels, you **must restart your R session** for the changes to take effect.

In RStudio:

1. Go to the **Session** menu
2. Select **Restart R**

Or use the keyboard shortcut: ``Ctrl+Shift+F10`` (Windows/Linux) or ``Cmd+Shift+F10`` (Mac)

Verifying the Switch
~~~~~~~~~~~~~~~~~~~~

After restarting, verify your R environment is using the new kernel:

.. code-block:: r

   # Check library paths - should include the kernel's library path
   .libPaths()
   
   # Check if expected packages are available
   library(package_name)

Troubleshooting
---------------

**"Using test data" warning appears**
   The Kernel Manager could not connect to the API server. This may indicate a network issue. Try clicking **Refresh** or contact your administrator.

**Kernel not appearing after use**
   Make sure you restarted your R session after running the "Use kernel" command.

**Command execution fails**
   Check the error message displayed below the command. Common issues include:
   
   - Kernel not found in catalog (try "Get kernel" first)
   - Permission issues (contact administrator)
   - Network connectivity problems

**Need more kernel information**
   Visit the kernel information web page (linked at the top of the dialog) for detailed package lists and advanced search capabilities.

Web Interface
-------------

For advanced searching and detailed kernel information, visit the ICRN Kernel Information web interface:

- **Production**: https://kernels.ncsa.illinois.edu

The web interface allows you to:

- Browse all kernels by language
- Search for specific packages across all kernels
- View complete package manifests for each kernel
- Copy CLI commands for kernel operations

