Configuration
=============

The ICRN Kernel Manager uses several configuration files and directories to manage kernel environments.

User Configuration
------------------

The manager creates the following structure in your home directory:

- ~/.icrn/
  - manager_config.json
  - icrn_kernels/
    - user_catalog.json
    - kernel-name-version/

Central Repository Structure
---------------------------

The central repository should have the following structure:

- /path/to/central/repo/
  - R/
    - icrn_kernel_catalog.json
    - kernel-name/
      - version/
        - kernel-name.tar.gz

Catalog Files
-------------

**manager_config.json** (user configuration):
.. code-block:: json

   {
     "icrn_central_catalog_path": "/path/to/central/repo",
     "icrn_r_kernels": "R",
     "icrn_python_kernels": "Python",
     "icrn_kernel_catalog": "icrn_kernel_catalog.json"
   }

**user_catalog.json** (user's local catalog):
.. code-block:: json

   {
     "kernel-name": {
       "version": {
         "absolute_path": "/path/to/unpacked/kernel"
       }
     }
   }

**icrn_kernel_catalog.json** (central catalog):
.. code-block:: json

   {
     "kernel-name": {
       "version": {
         "conda-pack": "kernel-name.tar.gz",
         "description": "Description of the kernel",
         "created": "2024-01-01",
         "maintainer": "maintainer@example.com"
       }
     }
   }

Environment Variables
--------------------

The following environment variables can be set to override defaults:

- ICRN_USER_BASE: Base directory for user files (default: ~/.icrn)
- ICRN_MANAGER_CONFIG: Path to manager config (default: ~/.icrn/manager_config.json)
- ICRN_USER_KERNEL_BASE: User kernel directory (default: ~/.icrn/icrn_kernels)
- ICRN_USER_CATALOG: User catalog file (default: ~/.icrn/icrn_kernels/user_catalog.json)

For more details, see the maintainer section. 