Installation
===========

The ICRN Kernel Manager is a bash script that requires minimal setup.

Prerequisites
-------------

- Bash shell
- jq (JSON processor)
- tar and gzip utilities
- conda or miniconda (for kernel creation)

Installation Steps
------------------

1. **Download the script**:
   Clone or download the icrn_manager script to your local machine.

2. **Make it executable**:
   .. code-block:: bash

      chmod +x icrn_manager

3. **Initialize the environment**:
   .. code-block:: bash

      ./icrn_manager kernels init <path to central repository>

   Example for production:
   .. code-block:: bash

      ./icrn_manager kernels init /sw/icrn/jupyter/icrn_ncsa_resources/Kernels

4. **Verify installation**:
   .. code-block:: bash

      ./icrn_manager kernels available

The script will create the necessary directories and configuration files in your home directory.

For more information, see the :doc:`user_guide`. 