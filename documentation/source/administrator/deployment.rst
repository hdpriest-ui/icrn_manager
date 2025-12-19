Deployment Overview
===================

The ICRN Kernel Manager consists of three main components that must be deployed:

1. **CLI Tool** (``icrn_manager``): Installed on user-accessible systems
2. **Kernel Indexer**: Containerized service that indexes kernel repositories
3. **Web Server**: FastAPI + Nginx service providing the web interface and API

Architecture
------------

.. code-block:: text

   Kernel Repository (shared filesystem)
       ↓ (read-write mount)
   Kernel Indexer (CronJob) → Generates collated_manifests.json & package_index.json
       ↓ (JSON files)
   Web Server (reads JSON files) → Serves REST API
       ↓
   CLI Tool & RStudio Addin → Users discover and manage kernels

Prerequisites
-------------

- Shared filesystem accessible to all components
- Container runtime (Docker or Apptainer/Singularity)
- Kubernetes cluster (for production deployment)
- Network access between components

Deploying the CLI Tool
----------------------

Copy the tools to a location in the system PATH:

.. code-block:: bash

   # Production paths
   cp ./icrn_manager /sw/icrn/prod/bin/
   cp ./update_r_libs.sh /sw/icrn/prod/bin/
   chmod +x /sw/icrn/prod/bin/icrn_manager
   chmod +x /sw/icrn/prod/bin/update_r_libs.sh

   # Development paths
   cp ./icrn_manager /sw/icrn/dev/bin/
   cp ./update_r_libs.sh /sw/icrn/dev/bin/
   chmod +x /sw/icrn/dev/bin/icrn_manager
   chmod +x /sw/icrn/dev/bin/update_r_libs.sh

Container Requirements
~~~~~~~~~~~~~~~~~~~~~~

Ensure user containers have ``jq`` installed, as it is required by ``icrn_manager``.

Environment Configuration
-------------------------

The kernel repository path is configured in the ``icrn_manager`` script. Update the ``KERNEL_FOLDER`` variable or configure via environment:

.. code-block:: bash

   # Default paths used by icrn_manager
   ICRN_USER_BASE=${ICRN_USER_BASE:-${HOME}/.icrn}
   ICRN_MANAGER_CONFIG=${ICRN_MANAGER_CONFIG:-${ICRN_USER_BASE}/manager_config.json}
   ICRN_USER_KERNEL_BASE=${ICRN_USER_KERNEL_BASE:-${ICRN_USER_BASE}/icrn_kernels}

Kubernetes Deployment
---------------------

For Kubernetes deployment configurations, see the ``kubernetes/`` directory in the repository.

Key resources:

- Kernel Indexer CronJob
- Web Server Deployment and Service
- ConfigMaps for environment configuration
- PersistentVolumeClaims for kernel storage

