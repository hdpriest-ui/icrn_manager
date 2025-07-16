Installation
============

Prerequisites
-------------
- Bash shell (Linux environment)
- jq (command-line JSON processor)
- conda (for managing R environments)

User Installation
-----------------
To initialize the Illinois Computes Library & Kernel Manager for your user account, run:

.. code-block:: bash

   ./icrn_manager libraries init <path to central repository>

Example for development work:

.. code-block:: bash

   ./icrn_manager libraries init /sw/icrn/jupyter/icrn_ncsa_resources/Kernels

This command can be run again to point at a different central repository, without disrupting your files.

Central Repository Setup
-----------------------
Administrators should prepare a central repository containing packed conda environments and a catalog file. See the :doc:`configuration` section for details. 