What Modules to Use (Campus Cluster Jupyter Kernels)
===================================================

When using Jupyter kernels on the Campus Cluster, you need to load the appropriate modules to access the required software and libraries.

Required Modules
---------------

For Jupyter kernels on Campus Cluster, typically load:

.. code-block:: bash

   module load python
   module load jupyter

GPU Support
-----------

For GPU-enabled kernels, also load:

.. code-block:: bash

   module load cuda
   module load cudnn

Optional Modules
---------------

Depending on your specific kernel requirements, you may also need:

.. code-block:: bash

   module load gcc
   module load openblas
   module load mkl

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
2. CUDA modules (for GPU support)
3. Python module
4. Jupyter module

Example Session
--------------

.. code-block:: bash

   # Load required modules
   module load python
   module load jupyter
   module load cuda  # For GPU support
   
   # Start Jupyter
   jupyter notebook

.. note::
   Module requirements may vary depending on the specific Jupyter kernel you're using. Check the kernel documentation for specific requirements. 