How to Remove Jupyter Kernel (ICRN)
==================================

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