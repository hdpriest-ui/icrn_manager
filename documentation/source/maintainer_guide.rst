Maintainer Guide
===============

This guide is for developers and engineers who wish to create and contribute new R library environments ("kernels") to the Illinois Computes Library & Kernel Manager central catalog. This is **not** for end-users who simply want to use existing kernels.

Overview
--------
The ICRN manager supports reproducible, shareable R environments by distributing pre-built, packed conda environments. This guide walks through the process of creating a new R kernel (using Bioconductor as an example), packaging it, and adding it to the central catalog.

.. note::
   For details on the central repository structure, see the :doc:`configuration` section.

Step 1: Create a New Conda Environment
--------------------------------------
Choose an R version that matches the ICRN platform. For example, to create an environment for Bioconductor:

.. code-block:: bash

   conda create --solver=libmamba -c r -y -n Rbioconductor r-base=4.4.2
   conda activate Rbioconductor

Step 2: Install Required R Packages
-----------------------------------
Install Bioconductor and any other packages needed:

.. code-block:: bash

   Rscript -e 'install.packages(c("BiocManager"), repos="http://cran.us.r-project.org")'
   Rscript -e 'BiocManager::install("edgeR")'

You can verify the installed packages:

.. code-block:: bash

   Rscript -e 'installed.packages()'

Note that it is at this point you should download, compile, and install all necessary software for the intended R kernel. You must use the package management systems embedded within 
The Conda environment you have created (e.g., pip, conda, R's install.packages, or as above, BiocManager::install() ). 

Installations or configuration done outside of the environment's 
file tree will not be included in the conda environment after packing, and will not be included with the kernel when it is leveraged by the user's R environment, leading to unpredictable behavior.


Step 3: Pack the Environment
----------------------------
Install `conda-pack` if not already present, then pack the environment:

.. code-block:: bash

   conda install -y --solver=libmamba conda-pack
   conda pack -n Rbioconductor -o ./Rbioconductor.tar.gz

This creates a portable tarball of the environment. Note that the location of the .tar.gz initially is unimportant, as you will move it into the appropriate location at a later time.

Step 4: Add to the Central Catalog
----------------------------------
(note: the below section will be changing in the near future with a build-out of tooling around catalog maintenance and update)

1. Place the packed tarball in the appropriate location in the central repository (see :doc:`configuration`).
2. Update the `icrn_kernel_catalog.json` file to include the new kernel and version. Example entry:

.. code-block:: json

   {
     "R": {
       "Rbioconductor": {
         "3.20": {
           "conda-pack": "Rbioconductor.tar.gz",
           "manifest": ""
         }
       }
     }
   }

Note that the version string (above: "3.20") is only a string, and therefore serves as a unqiue identifier for a specific tarball. It must be unique within the given Kernel stanza.


Step 5: Test the New Kernel
---------------------------
As a user, test the new kernel by running:

.. code-block:: bash

   # get the new kernel
   ./icrn_manager kernels get R Rbioconductor 3.20
   # use the new kernel
   ./icrn_manager kernels use R Rbioconductor 3.20
   # access contents of the new kernel via R
   # note that here - because we're using the new kernel, this actually accesses a different Rscript!
   Rscript -e 'BiocManager::version()'
   Rscript -e 'library(edgeR)'

You should see the correct Bioconductor version and be able to load the installed packages.

Tips and Troubleshooting
------------------------
- Be aware of the version of R the ICRN is using, how it aligns with the version in your custom environment, and especially how it matches the version of R for which the installed packages were developed for. Mismatches may cause unpredictable behavior.
- Restart R sessions after switching kernels.
- For more on the catalog structure, see :doc:`configuration`.
- For usage/testing, see :doc:`user_guide`.
