Usage
=====

This section provides detailed usage examples for the Illinois Computes Library & Kernel Manager.

Initial Setup
-------------

First, initialize the manager with a path to the central repository:

.. code-block:: bash

   ./icrn_manager kernels init /path/to/central/repository

Example for development:

.. code-block:: bash

   ./icrn_manager kernels init /u/hdpriest/icrn_temp_repository

This creates the necessary configuration files and directories in your home directory.

Discovering Available Kernels
-----------------------------

List all available kernels in the central catalog:

.. code-block:: bash

   ./icrn_manager kernels available

Example output:

.. code-block:: text

   Available kernels in ICRN catalog (/path/to/repo/icrn_kernel_catalog.json):
   Language	Kernel	Version
   R	cowsay	1.0
   R	mixRF	1.0
   R	pecan	1.9
   R	vctrs	1.0
   Python	numpy	1.20

This shows kernels organized by language (R, Python) with their available versions.

Checking Your Local Catalog
---------------------------

List kernels you have already checked out:

.. code-block:: bash

   ./icrn_manager kernels list

Example output:

.. code-block:: text

   checked out kernels in in user catalog (/home/user/.icrn/icrn_kernels/user_catalog.json):
   Language	Kernel	Version
   R	cowsay	1.0
   R	pecan	1.9

Getting a Kernel
---------------

Download and unpack a kernel from the central repository:

.. code-block:: bash

   ./icrn_manager kernels get <language> <kernel> <version>

Examples:

.. code-block:: bash

   # Get an R kernel
   ./icrn_manager kernels get R cowsay 1.0
   
   # Get a Python kernel
   ./icrn_manager kernels get Python numpy 1.20

This command:
- Downloads the kernel package from the central repository
- Unpacks it to your local directory
- Updates your user catalog with the kernel information

Using a Kernel
-------------

Activate a kernel for your current session:

.. code-block:: bash

   ./icrn_manager kernels use <language> <kernel> <version>

Examples:

.. code-block:: bash

   # Use an R kernel
   ./icrn_manager kernels use R cowsay 1.0
   
   # Use a Python kernel
   ./icrn_manager kernels use Python numpy 1.20

This command:
- Updates your R environment to use the specified kernel
- Only one kernel can be active at a time
- The kernel remains active until you switch to another or deactivate

Switching Between Kernels
-------------------------

Switch from one kernel to another:

.. code-block:: bash

   ./icrn_manager kernels use R pecan 1.9

Stop using any kernel:

.. code-block:: bash

   ./icrn_manager kernels use none

Managing Your Local Kernels
---------------------------

Remove a kernel completely (files and catalog entry):

.. code-block:: bash

   ./icrn_manager kernels remove <language> <kernel> <version>

Example:

.. code-block:: bash

   ./icrn_manager kernels remove R cowsay 1.0

Clean a kernel entry from your catalog (keeps files):

.. code-block:: bash

   # Remove specific version
   ./icrn_manager kernels clean <language> <kernel> <version>
   
   # Remove all versions of a kernel
   ./icrn_manager kernels clean <language> <kernel>

Examples:

.. code-block:: bash

   # Clean specific version
   ./icrn_manager kernels clean R cowsay 1.0
   
   # Clean all versions of a kernel
   ./icrn_manager kernels clean R cowsay

Common Workflows
----------------

**Scenario 1: First-time setup and use (R)**

.. code-block:: bash

   # Initialize
   ./icrn_manager kernels init /path/to/repo
   
   # See what's available
   ./icrn_manager kernels available
   
   # Get a kernel
   ./icrn_manager kernels get R cowsay 1.0
   
   # Use the kernel
   ./icrn_manager kernels use R cowsay 1.0

**Scenario 2: First-time setup and use (Python)**

.. code-block:: bash

   # Initialize
   ./icrn_manager kernels init /path/to/repo
   
   # See what's available
   ./icrn_manager kernels available
   
   # Get a Python kernel
   ./icrn_manager kernels get Python numpy 1.24.0
   
   # Use the kernel (this installs it in Jupyter)
   ./icrn_manager kernels use Python numpy 1.24.0
   
   # The kernel is now available in Jupyter notebooks

**Scenario 3: Switching between kernels**

.. code-block:: bash

   # Stop current kernel
   ./icrn_manager kernels use none
   
   # Switch to different kernel
   ./icrn_manager kernels use R pecan 1.9

**Scenario 4: Clean slate**

.. code-block:: bash

   # Stop using kernels
   ./icrn_manager kernels use none
   
   # Remove kernel files and entries
   ./icrn_manager kernels remove R cowsay 1.0
   
   # Or just clean catalog entries
   ./icrn_manager kernels clean R cowsay 1.0

Python Kernel Specific Workflows
--------------------------------

**Python Kernel Installation and Use**

Python kernels work differently from R kernels. When you use a Python kernel, it gets installed into your Jupyter environment:

.. code-block:: bash

   # Get a Python kernel
   ./icrn_manager kernels get Python numpy 1.24.0
   
   # Use the kernel (installs it in Jupyter)
   ./icrn_manager kernels use Python numpy 1.24.0
   
   # The kernel "numpy-1.24.0" is now available in Jupyter notebooks
   # You can select it from the kernel menu in Jupyter

**Python Kernel Removal**

To remove Python kernels from Jupyter:

.. code-block:: bash

   # Remove all Python kernels from Jupyter
   ./icrn_manager kernels use Python none
   
   # This uses 'jupyter kernelspec uninstall' to remove kernels

**Python Kernel Management**

Python kernels are stored in language-specific directories:

.. code-block:: text

   ~/.icrn/icrn_kernels/
   ├── r/                    # R kernels
   │   └── cowsay-1.0/
   └── python/               # Python kernels
       └── numpy-1.24.0/

**Verifying Python Kernel Installation**

You can verify that your Python kernel was installed correctly:

.. code-block:: bash

   # List all available Jupyter kernels
   jupyter kernelspec list
   
   # You should see your kernel listed, e.g.:
   # Available kernels:
   #   numpy-1.24.0    /home/user/.local/share/jupyter/kernels/numpy-1.24.0

Troubleshooting
---------------

If you encounter issues:

1. **Check your catalog**: Use `./icrn_manager kernels list` to see what kernels you have
2. **Verify availability**: Use `./icrn_manager kernels available` to see what's in the central catalog
3. **Clean and retry**: Use `./icrn_manager kernels clean` to remove problematic entries
4. **Start fresh**: Use `./icrn_manager kernels remove` to completely remove a kernel

For more detailed troubleshooting, see the :doc:`troubleshooting` section. 