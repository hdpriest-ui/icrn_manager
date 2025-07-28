How to Switch R Kernels (ICRN)
=============================

Switching between R kernels in the ICRN environment allows you to use different R library configurations.

Using the icrn_manager Tool
--------------------------

To switch to a different R kernel:

.. code-block:: bash

   icrn_manager kernels use R <kernel_name> <version>

Example:

.. code-block:: bash

   icrn_manager kernels use R Rbioconductor 3.20

This command will:

1. Activate the specified R kernel
2. Update your R environment configuration
3. Make the kernel available in RStudio and Jupyter

Verifying the Switch
-------------------

After switching, you can verify the active kernel:

.. code-block:: bash

   icrn_manager kernels list

This will show your currently installed and active kernels.

Restarting R
------------

After switching kernels, restart your R session to ensure the new environment is loaded:

1. In RStudio: Session → Restart R
2. In Jupyter: Kernel → Restart

.. note::
   Always restart your R session after switching kernels to ensure the new environment is properly loaded. 