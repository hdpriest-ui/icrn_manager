How to Pick a Jupyter Kernel (Campus Cluster)
============================================

To pick a Jupyter kernel on the Campus Cluster:

1. **Load required modules**:
   .. code-block:: bash

      module load python
      module load jupyter

2. **List available kernels**:
   .. code-block:: bash

      icrn_manager kernels available

3. **Get the desired kernel**:
   .. code-block:: bash

      icrn_manager kernels get Python <kernel_name> <version>

4. **Use the kernel**:
   .. code-block:: bash

      icrn_manager kernels use Python <kernel_name> <version>

5. **Start Jupyter**:
   .. code-block:: bash

      jupyter notebook

6. **Select the kernel**:
   - In JupyterLab: Click the kernel selector in the top right
   - In Jupyter Notebook: Kernel → Change kernel

.. note::
   Always restart your Jupyter session after switching kernels to ensure the new environment is properly loaded. 