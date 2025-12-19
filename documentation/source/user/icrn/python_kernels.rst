Python Kernels in ICRN
=====================

This guide walks you through the process of adding and using Python kernels in the ICRN Jupyter environment.

Prerequisites
------------

Before starting, ensure you have access to the ICRN environment and the ``icrn_manager`` tool is available.

Step 1: Check Available Kernels
-------------------------------

First, let's see what Python kernels are available in the ICRN catalog:

.. code-block:: bash

   icrn_manager kernels avail

This will show you all available kernels, including Python kernels. For example:

.. code-block:: text

   Available kernels in ICRN catalog (/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/icrn_kernel_catalog.json):
   Language        Kernel  Version
   Python  astro   1.0
   R       Rbioconductor   3.20
   R       mixRF   1.0
   R       pecan   1.9

Step 2: Get a Python Kernel
---------------------------

To add a Python kernel to your environment, use the ``get`` command:

.. code-block:: bash

   ./icrn_manager kernels get Python astro 1.0

This command will:

1. Download the kernel package from the central repository
2. Extract it to your local environment
3. Update your user catalog

You should see output similar to:

.. code-block:: text

   Desired kernel:
   Language: Python
   Kernel: astro
   Version: 1.0

   ICRN Catalog:
   /sw/icrn/jupyter/icrn_ncsa_resources/Kernels/icrn_kernel_catalog.json
   User Catalog:
   /home/hdpriest/.icrn/icrn_kernels/user_catalog.json

   Making target directory: /home/hdpriest/.icrn/icrn_kernels/python/astro-1.0/
   Checking out kernel...
   checking for: /home/hdpriest/.icrn/icrn_kernels/python/astro-1.0/bin/activate
   activating environment
   doing unpack
   deactivating
   Updating user's catalog with Python astro and 1.0
   Done.

   Be sure to call "icrn_manager kernels use Python astro 1.0" to begin using this kernel in Python.

Step 3: Install the Kernel in Jupyter
------------------------------------

After getting the kernel, you need to install it in Jupyter:

.. code-block:: bash

   icrn_manager kernels use Python astro 1.0

This will install the kernel and make it available in Jupyter. You should see:

.. code-block:: text

   Desired kernel:
   Language: Python
   Kernel: astro
   Version: 1.0
   checking for: /home/hdpriest/.icrn/icrn_kernels/python/astro-1.0/
   Found. Activating Python kernel...
   Installing Python kernel: astro-1.0
   Installed kernelspec astro-1.0 in /home/hdpriest/.local/share/jupyter/kernels/astro-1.0
   Python kernel installation complete.
   Kernel 'astro-1.0' is now available in Jupyter.

Step 4: Use the Kernel in Jupyter
---------------------------------

Now you can use the kernel in Jupyter:

1. **Open Jupyter Notebook or JupyterLab**

2. **Check Available Kernels**
   
   Before the kernel appears, you might see only the default kernels:

   .. image:: ../../_static/images/Jupyter_kernels_noastro.png
      :alt: Jupyter kernels list without astro kernel
      :width: 600px

3. **Restart the Kernel**
   
   After installing a new kernel, restart your Jupyter kernel to refresh the kernel list:

   .. image:: ../../_static/images/jupyter_restart_kernel.png
      :alt: Restart kernel option in Jupyter
      :width: 600px

4. **Select the New Kernel**
   
   After restarting, you should see your new kernel in the kernel selection menu:

   .. image:: ../../_static/images/jupyter-kernels-astro-avail.png
      :alt: Jupyter kernels list with astro kernel available
      :width: 600px

5. **Change to the New Kernel**
   
   Use the kernel menu to switch to your new Python kernel:

   .. image:: ../../_static/images/Jupyter-menu-change-kernel.png
      :alt: Jupyter menu to change kernel
      :width: 600px

6. **Verify the Kernel is Running**
   
   Once selected, you should see the kernel name in the top right of your notebook:

   .. image:: ../../_static/images/jupyter_running_astro.png
      :alt: Jupyter notebook running astro kernel
      :width: 600px

Managing Python Kernels
----------------------

**List Your Installed Kernels**

.. code-block:: bash

   icrn_manager kernels list

**Remove a Python Kernel**

To remove a Python kernel from Jupyter (but keep the files):

.. code-block:: bash

   icrn_manager kernels use Python none


Troubleshooting
--------------

**Kernel Not Appearing in Jupyter**

1. Make sure you ran the ``use`` command after the ``get`` command
2. Restart your Jupyter kernel
3. Check that the kernel was installed correctly:

   .. code-block:: bash

      jupyter kernelspec list

**Permission Errors**

If you encounter permission errors, ensure you have write access to your home directory and the Jupyter kernel directory.

**Kernel Installation Fails**

If kernel installation fails:

1. Check that the kernel package was downloaded correctly
2. Verify your user catalog is properly configured

For more help, see the :doc:`../../troubleshooting` guide. 