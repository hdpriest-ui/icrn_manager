Slurm Batch Job Examples (Campus Cluster)
========================================

.. warning::
   **PLACEHOLDER CONTENT**: This process has not ever been attempted. These examples are theoretical and have not been tested in practice.

This section provides example SLURM batch job scripts for different kernel types on the Campus Cluster.

R Kernel Batch Job
------------------

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=r_kernel_job
   #SBATCH --output=r_kernel_job_%j.out
   #SBATCH --error=r_kernel_job_%j.err
   #SBATCH --time=01:00:00
   #SBATCH --nodes=1
   #SBATCH --ntasks=1
   #SBATCH --cpus-per-task=4
   #SBATCH --mem=8G

   # Load required modules
   module load R
   module load jupyter

   # Get and use R kernel
   icrn_manager kernels get R <kernel_name> <version>
   icrn_manager kernels use R <kernel_name> <version>

   # Run R script
   Rscript my_analysis.R

Python Kernel Batch Job
----------------------

.. code-block:: bash

   #!/bin/bash
   #SBATCH --job-name=python_kernel_job
   #SBATCH --output=python_kernel_job_%j.out
   #SBATCH --error=python_kernel_job_%j.err
   #SBATCH --time=01:00:00
   #SBATCH --nodes=1
   #SBATCH --ntasks=1
   #SBATCH --cpus-per-task=4
   #SBATCH --mem=8G

   # Load required modules
   module load python
   module load jupyter

   # Get and use Python kernel
   icrn_manager kernels get Python <kernel_name> <version>
   icrn_manager kernels use Python <kernel_name> <version>

   # Run Python script
   python my_analysis.py

