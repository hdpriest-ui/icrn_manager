What Modules to Load (Campus Cluster R Kernels)
==============================================

When using R kernels on the Campus Cluster, you need to load the appropriate modules to access the required software and libraries.

Required Modules
---------------

For R kernels on Campus Cluster, typically load:

.. code-block:: bash

   module load R
   module load jupyter

Optional Modules
---------------

Depending on your specific kernel requirements, you may also need:

.. code-block:: bash

   module load python
   module load gcc
   module load openblas

Checking Available Modules
------------------------

To see what modules are available:

.. code-block:: bash

   module avail

To see currently loaded modules:

.. code-block:: bash

   module list

Module Loading Order
-------------------

Load modules in this order:

1. Compiler modules (if needed)
2. R module
3. Python module (if needed)
4. Jupyter module

Example Session
--------------

.. code-block:: bash

   # Load required modules
   module load R
   module load jupyter
   
   # Start Jupyter
   jupyter notebook

.. note::
   Module requirements may vary depending on the specific R kernel you're using. Check the kernel documentation for specific requirements. 