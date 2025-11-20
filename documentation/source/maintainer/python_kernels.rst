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
- Documentation and examples
- Version metadata

For detailed instructions on creating Python kernels, see the kernel creation documentation.

.. toctree::
   :maxdepth: 1

   jupyter_pieces

Indexing Kernels
----------------

The ``kernel_indexer`` script can be used to create package manifests and inventory all kernels in a repository. This is useful for:

- Tracking which packages are included in each kernel
- Generating package inventories for documentation
- Creating indexes for package discovery

To index all Python kernels in a repository:

.. code-block:: bash

   ./kernel_indexer index --kernel-root /path/to/repository --language Python

This creates a ``package_manifest.json`` file in each kernel directory containing:
- Kernel name and version
- Language and language version
- Complete list of packages with versions and sources
- Indexing timestamp

To create collated indexes for all kernels:

.. code-block:: bash

   # Create kernel-centric index (list of all kernels)
   ./kernel_indexer collate-by-kernels --kernel-root /path/to/repository --language Python --output collated_manifests.json

   # Create package-centric index (which kernels contain each package)
   ./kernel_indexer collate-by-packages --kernel-root /path/to/repository --language Python --output package_index.json

   # Or create both at once
   ./kernel_indexer collate --kernel-root /path/to/repository --language Python --output-dir /path/to/output

.. note::
   Detailed step-by-step instructions for creating Python kernels are available in the kernel creation documentation. 