Usage
=====

The Illinois Computes Library & Kernel Manager provides several subcommands for managing R library environments. Below are common usage patterns and examples.

List Available Libraries
------------------------
.. code-block:: bash

   ./icrn_manager libraries available

This command lists all available libraries and their versions in the central catalog.

Get a Library
-------------
.. code-block:: bash

   ./icrn_manager libraries get <library> <version>

Example:

.. code-block:: bash

   ./icrn_manager libraries get cowsay 1.0

This downloads and unpacks the specified library environment, updating your user catalog.

Use a Library
-------------
.. code-block:: bash

   ./icrn_manager libraries use <library> <version>

Example:

.. code-block:: bash

   ./icrn_manager libraries use cowsay 1.0

This activates the specified library for your R session by updating your ~/.Renviron file.

Switch Libraries
----------------
.. code-block:: bash

   ./icrn_manager libraries use <other-library> <version>

Stop Using Libraries
--------------------
.. code-block:: bash

   ./icrn_manager libraries use none

List Checked Out Libraries
-------------------------
.. code-block:: bash

   ./icrn_manager libraries list

Remove a Library
----------------
.. code-block:: bash

   ./icrn_manager libraries remove <library> <version>

Clean User Catalog Entry
------------------------
.. code-block:: bash

   ./icrn_manager libraries clean <library> <version>

For more details on each command, see the :doc:`reference` section. 