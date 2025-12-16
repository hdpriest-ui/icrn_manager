Kernel Indexer
==============

The kernel indexer is a containerized service that scans kernel repositories and generates JSON manifest files for the web interface and API.

Output Files
------------

The indexer generates two key files:

``collated_manifests.json``
   Kernel-centric index listing all available kernels with their packages

``package_index.json``
   Package-centric index showing which kernels contain each package

Building the Container
----------------------

.. code-block:: bash

   docker build -t icrn-kernel-indexer:latest -f kernel-indexer/Dockerfile .

Running the Indexer
-------------------

Docker
~~~~~~

The indexer requires read-write access to the kernel repository:

.. code-block:: bash

   docker run --rm \
     -v /path/to/kernel/repository:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
     -e KERNEL_ROOT=/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
     icrn-kernel-indexer:latest

Apptainer/Singularity
~~~~~~~~~~~~~~~~~~~~~

For HPC environments using Apptainer:

.. code-block:: bash

   # Pull the container
   apptainer pull docker://hdpriest0uiuc/icrn-kernel-indexer

   # Run with custom kernel root (development)
   apptainer run \
     --env "KERNEL_ROOT=/sw/icrn/dev/kernels" \
     --bind /sw/icrn/dev/kernels:/sw/icrn/dev/kernels \
     icrn-kernel-indexer_latest.sif

   # Run with default paths (production)
   apptainer run \
     --bind /sw/icrn/jupyter/icrn_ncsa_resources/Kernels:/sw/icrn/jupyter/icrn_ncsa_resources/Kernels \
     icrn-kernel-indexer_latest.sif

Environment Variables
---------------------

``KERNEL_ROOT``
   Path to the root directory containing kernel subdirectories. Defaults to ``/sw/icrn/jupyter/icrn_ncsa_resources/Kernels``.

Kubernetes CronJob
------------------

For production, deploy the indexer as a Kubernetes CronJob to automatically re-index kernels on a schedule.

See ``kernel-indexer/README.md`` for detailed Kubernetes deployment instructions.

Manual Indexing
---------------

The ``kernel_indexer`` script can also be run directly for manual operations:

.. code-block:: bash

   # Index all R kernels
   ./kernel_indexer index --kernel-root /path/to/repository --language R

   # Create kernel-centric index
   ./kernel_indexer collate-by-kernels --kernel-root /path/to/repository --language R --output collated_manifests.json

   # Create package-centric index
   ./kernel_indexer collate-by-packages --kernel-root /path/to/repository --language R --output package_index.json

   # Create both indexes at once
   ./kernel_indexer collate --kernel-root /path/to/repository --language R --output-dir /path/to/output

