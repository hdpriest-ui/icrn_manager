ICRN Jupyter Kernel (User)
=========================

This section provides user guides for Jupyter kernels in the ICRN environment.

How to Add Jupyter Kernel
-------------------------

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

How to Remove Jupyter Kernel
----------------------------

To remove a Jupyter kernel from your ICRN environment:

1. **Stop using the kernel**:

   .. code-block:: bash

      icrn_manager kernels use Python none

2. **Remove the kernel**:

   .. code-block:: bash

      icrn_manager kernels remove Python <kernel_name> <version>

3. **Clean up catalog entry**:

   .. code-block:: bash

      icrn_manager kernels clean Python <kernel_name> <version>

4. **Verify removal**:

   .. code-block:: bash

      jupyter kernelspec list

.. note::
   Always restart your Jupyter session after making changes to kernel configurations. 