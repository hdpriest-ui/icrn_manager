Kernel Creation
==============

This guide explains how to create new kernels for the Illinois Computes Library & Kernel Manager system.

Overview
--------
Kernels are pre-packaged environments that contain specific software and dependencies. They are distributed as conda-packed environments and managed through a hierarchical catalog structure organized by language.

Creating a New Kernel
--------------------

1. **Set up the environment**:
   .. code-block:: bash

      conda create --solver=libmamba -c r -y -n my_kernel r-base=4.4.2
      conda activate my_kernel

2. **Install required packages**:
   .. code-block:: bash

      Rscript -e 'install.packages(c("package1", "package2"), repos="http://cran.us.r-project.org")'

3. **Pack the environment**:
   .. code-block:: bash

      conda install -y --solver=libmamba conda-pack
      conda pack -n my_kernel -o ./my_kernel.tar.gz

4. **Add to the catalog**:
   Update the `icrn_kernel_catalog.json` file in the base repository directory:
   .. code-block:: json

      {
        "R": {
          "my_kernel": {
            "1.0": {
              "conda-pack": "my_kernel.tar.gz",
              "manifest": ""
            }
          }
        }
      }

5. **Test the kernel**:
   .. code-block:: bash

      ./icrn_manager kernels get R my_kernel 1.0
      ./icrn_manager kernels use R my_kernel 1.0

Directory Structure
------------------
The central repository should be organized by language:

.. code-block:: text

   central_repository/
   ├── icrn_kernel_catalog.json
   ├── r_kernels/
   │   ├── my_kernel/
   │   │   └── 1.0/
   │   │       └── my_kernel.tar.gz
   │   └── ...
   ├── python_kernels/
   │   └── ...
   └── ...

For more detailed instructions, see the :doc:`maintainer_guide` section.
