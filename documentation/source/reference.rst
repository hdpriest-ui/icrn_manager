Reference
=========

This section documents each subcommand of the Illinois Computes Library & Kernel Manager CLI.

Subcommands
-----------

- **init**

  .. code-block:: bash

     ./icrn_manager libraries init [<central_repo_path>]

  Initialize user configuration and point to a central repository.

- **available** (alias: avail)

  .. code-block:: bash

     ./icrn_manager libraries available

  List all available libraries and versions in the central catalog.

- **list**

  .. code-block:: bash

     ./icrn_manager libraries list

  List all libraries currently checked out and available for use in your user catalog.

- **get**

  .. code-block:: bash

     ./icrn_manager libraries get <library> <version>

  Download and unpack a library environment from the central repository.

- **use** (alias: activate)

  .. code-block:: bash

     ./icrn_manager libraries use <library> <version>
     ./icrn_manager libraries use none

  Activate a library for your R session, or deactivate all libraries.

- **remove**

  .. code-block:: bash

     ./icrn_manager libraries remove <library> <version>

  Remove a checked-out library and its files from your user space.

- **clean**

  .. code-block:: bash

     ./icrn_manager libraries clean <library> <version>

  Remove a library entry from your user catalog (does not delete files).

- **update**

  .. code-block:: bash

     ./icrn_manager libraries update <library> <version>

  (Not yet implemented) Update a checked-out library to the latest version from the central repository.

For help, run:

.. code-block:: bash

   ./icrn_manager help 