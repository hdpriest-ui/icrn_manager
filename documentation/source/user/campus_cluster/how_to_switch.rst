How to Switch R Kernels (Campus Cluster)
=======================================

To switch R kernels on the Campus Cluster:

1. **Load required modules**:
   .. code-block:: bash

      module load R
      module load jupyter

2. **Switch kernels**:
   .. code-block:: bash

      icrn_manager kernels use R <kernel_name> <version>

3. **Restart R session**:
   - In RStudio: Session → Restart R
   - In Jupyter: Kernel → Restart

4. **Verify the switch**:
   .. code-block:: bash

      icrn_manager kernels list

.. note::
   Always restart your R session after switching kernels to ensure the new environment is properly loaded. 