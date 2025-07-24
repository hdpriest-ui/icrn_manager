Reference
=========

This section documents each subcommand of the Illinois Computes Library & Kernel Manager CLI.

Subcommands
-----------

- **init**

  .. code-block:: bash

     ./icrn_manager kernels init [<central_repo_path>]

  Initialize user configuration and point to a central repository.

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

For help, run:

.. code-block:: bash

   ./icrn_manager help 