How to Restart R Kernels (ICRN)
==============================

Restarting R kernels is necessary after switching between different R library environments to ensure the new configuration is properly loaded.

When to Restart
--------------

Restart your R session when:

- Switching between different R kernels
- Installing new packages
- Updating kernel configurations
- Experiencing package conflicts

How to Restart
--------------

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
--------------------

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