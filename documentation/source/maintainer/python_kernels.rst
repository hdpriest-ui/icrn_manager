Python Kernels (Maintainer)
==========================

This section provides guidance for maintainers on creating and managing Python kernels for the ICRN platform.

Creating Python Kernels
----------------------

Python kernels are virtual environments that contain specific Python packages and configurations. They are distributed as compressed archives and managed through the central catalog.

Kernel Structure
---------------

A Python kernel typically includes:

- Python packages and dependencies
- Virtual environment configuration
- Jupyter kernel specification
- Documentation and examples
- Version metadata

Jupyter Integration
------------------

Python kernels must be properly configured for Jupyter:

- Kernel specification files
- Environment activation scripts
- Package compatibility verification

For detailed instructions on creating Python kernels, see the :doc:`maintainer_guide` section.

.. toctree::
   :maxdepth: 1

   jupyter_pieces

.. note::
   Detailed step-by-step instructions for creating Python kernels are available in the maintainer guide. 