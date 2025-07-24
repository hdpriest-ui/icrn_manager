Troubleshooting
==============

Common issues and solutions when using the Illinois Computes Library & Kernel Manager.

Common Errors
-------------

- **Error**: "usage: icrn_manager kernels get <language> <kernel name> <version number>"

  **Solution**: Make sure to include the language parameter (R, Python, etc.) in your command:
  
  .. code-block:: bash

     ./icrn_manager kernels get R cowsay 1.0

- **Error**: "Could not find target kernel to get"

  **Solution**: Check that the kernel exists in the central catalog:
  
  .. code-block:: bash

     ./icrn_manager kernels available

- **Error**: "Path could not be found. There is a problem with your user catalog."

  **Solution**: Clean the problematic entry and re-download:
  
  .. code-block:: bash

     ./icrn_manager kernels clean <language> <kernel> <version>
     ./icrn_manager kernels get <language> <kernel> <version>

- **Error**: "Couldn't locate ICRN's central catalog"

  **Solution**: Re-initialize the manager with the correct path:
  
  .. code-block:: bash

     ./icrn_manager kernels init /path/to/central/repository

Environment Issues
-----------------

- **R packages not loading**: Make sure you've activated the kernel:
  
  .. code-block:: bash

     ./icrn_manager kernels use <language> <kernel> <version>

- **Multiple kernels conflicting**: Only one kernel can be active at a time. Switch or deactivate:
  
  .. code-block:: bash

     ./icrn_manager kernels use none
     ./icrn_manager kernels use <language> <kernel> <version>

For more help, see the :doc:`usage` section. 