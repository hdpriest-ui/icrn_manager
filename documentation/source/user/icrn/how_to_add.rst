How to Add Jupyter Kernel (ICRN)
===============================

To add a Jupyter kernel to your ICRN environment:

1. **Get the kernel**:
   .. code-block:: bash

      icrn_manager kernels get Python <kernel_name> <version>

2. **Use the kernel**:
   .. code-block:: bash

      icrn_manager kernels use Python <kernel_name> <version>

3. **Verify installation**:
   .. code-block:: bash

      jupyter kernelspec list

4. **Restart Jupyter**:
   - In JupyterLab: Kernel → Restart All Kernels
   - In Jupyter Notebook: Kernel → Restart

.. note::
   Always restart your Jupyter session after making changes to kernel configurations. 