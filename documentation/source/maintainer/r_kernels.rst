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

Indexing Kernels
----------------

The ``kernel_indexer`` script can be used to create package manifests and inventory all kernels in a repository. This is useful for:

- Tracking which packages are included in each kernel
- Generating package inventories for documentation
- Creating indexes for package discovery

To index all R kernels in a repository:

.. code-block:: bash

   ./kernel_indexer index --kernel-root /path/to/repository --language R

This creates a ``package_manifest.json`` file in each kernel directory containing:
- Kernel name and version
- Language and language version
- Complete list of packages with versions and sources
- Indexing timestamp

To create collated indexes for all kernels:

.. code-block:: bash

   # Create kernel-centric index (list of all kernels)
   ./kernel_indexer collate-by-kernels --kernel-root /path/to/repository --language R --output collated_manifests.json

   # Create package-centric index (which kernels contain each package)
   ./kernel_indexer collate-by-packages --kernel-root /path/to/repository --language R --output package_index.json

   # Or create both at once
   ./kernel_indexer collate --kernel-root /path/to/repository --language R --output-dir /path/to/output 