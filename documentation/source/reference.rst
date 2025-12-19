Reference
=========

This section documents each subcommand of the Illinois Computes Library & Kernel Manager CLI.

Subcommands
-----------

- **available** (alias: avail)

  .. code-block:: bash

     ./icrn_manager kernels available

  List all available kernels and versions in the central catalog, organized by language.

- **list**

  .. code-block:: bash

     ./icrn_manager kernels list

  List all kernels currently checked out and available for use in your user catalog, organized by language.

- **get**

  .. code-block:: bash

     ./icrn_manager kernels get <language> <kernel> <version>

  Download and unpack a kernel environment from the central repository.

- **use** (alias: activate)

  .. code-block:: bash

     ./icrn_manager kernels use <language> <kernel> <version>
     ./icrn_manager kernels use none

  Activate a kernel for your R session, or deactivate all kernels.

- **remove**

  .. code-block:: bash

     ./icrn_manager kernels remove <language> <kernel> <version>

  Remove a checked-out kernel and its files from your user space.

- **clean**

  .. code-block:: bash

     ./icrn_manager kernels clean <language> <kernel> <version>

  Remove a kernel entry from your user catalog (does not delete files).

- **update**

  .. code-block:: bash

     ./icrn_manager kernels update <language> <kernel> <version>

  (Not yet implemented) Update a checked-out kernel to the latest version from the central repository.

Kernel Indexer
---------------

The ``kernel_indexer`` script indexes kernels and generates package manifests for inventory and management purposes.

**index**

.. code-block:: bash

   ./kernel_indexer index --kernel-root <PATH> [--language <LANG>] [--kernel-name <NAME>] [--kernel-version <VER>]

  Index kernels and generate manifest files. Discovers all kernels in the repository and extracts package information from conda environments and language-specific package managers (e.g., R packages).

  - ``--kernel-root``: Path to kernel repository root (required if not in config)
  - ``--language``: Filter by specific language (R, Python). If omitted, processes all languages
  - ``--kernel-name``: Index only a specific kernel (optional)
  - ``--kernel-version``: Index only a specific version (requires --kernel-name)

**collate-by-kernels**

.. code-block:: bash

   ./kernel_indexer collate-by-kernels --kernel-root <PATH> [--language <LANG>] [--output <PATH>]

  Collate all manifest files into a kernel-centric index. Creates a JSON file listing all indexed kernels with their metadata and package counts.

  - ``--kernel-root``: Path to kernel repository root (required if not in config)
  - ``--language``: Filter by specific language (R, Python). If omitted, processes all languages
  - ``--output``: Path for collated manifest (default: {kernel-root}/collated_manifests.json)

**collate-by-packages**

.. code-block:: bash

   ./kernel_indexer collate-by-packages --kernel-root <PATH> [--language <LANG>] [--output <PATH>]

  Collate manifests into a package-centric index. Creates a JSON file listing all packages with information about which kernels contain them.

  - ``--kernel-root``: Path to kernel repository root (required if not in config)
  - ``--language``: Filter by specific language (R, Python). If omitted, processes all languages
  - ``--output``: Path for package-centric index (default: {kernel-root}/package_index.json)

**collate**

.. code-block:: bash

   ./kernel_indexer collate --kernel-root <PATH> [--language <LANG>] [--output-dir <DIR>]

  Run both collate-by-kernels and collate-by-packages operations. Creates both index files in the specified output directory.

  - ``--kernel-root``: Path to kernel repository root (required if not in config)
  - ``--language``: Filter by specific language (R, Python). If omitted, processes all languages
  - ``--output-dir``: Directory for output files (default: {kernel-root})

For help, run:

.. code-block:: bash

   ./icrn_manager help
   ./kernel_indexer 