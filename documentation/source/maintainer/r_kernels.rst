R Kernels (Maintainer)
======================

This section provides guidance for maintainers on creating and managing R kernels for the ICRN platform.

Creating R Kernels
-----------------

R kernels are packaged environments that contain specific R packages and configurations. They are distributed as compressed archives and managed through the central catalog.

Kernel Structure
---------------

An R kernel typically includes:

- R packages and dependencies
- Environment configuration files
- Documentation and examples
- Version metadata

For detailed instructions on creating R kernels, see the kernel creation documentation.

Testing Kernels
--------------

Before distributing kernels, ensure they:

- Install correctly in the target environment
- Include all required dependencies
- Work with the ICRN Jupyter environment
- Pass validation tests

.. note::
   Detailed step-by-step instructions for creating R kernels are available in the kernel creation documentation. 