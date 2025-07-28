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

Adding Jupyter Pieces
--------------------

To make Python kernels available in Jupyter:

1. **Create kernel spec directory**:
   .. code-block:: bash

      mkdir -p /path/to/kernel/spec/kernel.json

2. **Create kernel.json**:
   .. code-block:: json

      {
        "argv": ["/path/to/python/env/bin/python", "-m", "ipykernel_launcher", "-f", "{connection_file}"],
        "display_name": "Python (Kernel Name)",
        "language": "python"
      }

3. **Install ipykernel**:
   .. code-block:: bash

      pip install ipykernel
      python -m ipykernel install --user --name kernel_name --display-name "Python (Kernel Name)"

For detailed instructions on creating Python kernels, see the kernel creation documentation.

.. toctree::
   :maxdepth: 1

   jupyter_pieces

.. note::
   Detailed step-by-step instructions for creating Python kernels are available in the kernel creation documentation. 