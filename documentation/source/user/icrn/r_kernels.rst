ICRN R Kernels (User)
=====================

This section provides user guides for R kernels in the ICRN environment.

How to Switch R Kernels
-----------------------

Switching between R kernels in the ICRN environment allows you to use different R library configurations.

Using the icrn_manager Tool
~~~~~~~~~~~~~~~~~~~~~~~~~~

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
~~~~~~~~~~~~~~~~~~~

After switching, you can verify the active kernel:

.. code-block:: bash

   icrn_manager kernels list

This will show your currently installed and active kernels.

How to Restart R Kernels
------------------------

Restarting R kernels is necessary after switching between different R library environments to ensure the new configuration is properly loaded.

When to Restart
~~~~~~~~~~~~~~

Restart your R session when:

- Switching between different R kernels
- Installing new packages
- Updating kernel configurations
- Experiencing package conflicts

How to Restart
~~~~~~~~~~~~~

In RStudio:
1. Go to the **Session** menu
2. Select **Restart R**

In Jupyter:
1. Go to the **Kernel** menu
2. Select **Restart**

In R Console:
1. Use the `q()` command to quit
2. Restart R from the command line

Verifying the Restart
~~~~~~~~~~~~~~~~~~~~

After restarting, verify your R environment:

.. code-block:: r

   # Check loaded packages
   .packages()
   
   # Check R version
   R.version.string
   
   # Check library paths
   .libPaths()

.. note::
   Always restart your R session after switching kernels to ensure the new environment is properly loaded. 