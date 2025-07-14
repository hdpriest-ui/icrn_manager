Usage
=====

The Illinois Computes Library & Kernel Manager provides several subcommands for managing R library environments. Below are common usage patterns and examples.

Recommended Usage
-----------------
The custom kernels which are accessible through this system are intended for use in addition to common R packages which you may already be familiar with. 
It is recommended that you regard these kernels as the 'final layer' to your R environment before beginning your work. It is best to maintain a habit of working with your
native R environment (i.e., without kernels in use), and only check-out and use these kernels on an as-needed basis. 

Getting into the habit of working without these kernels will enable you to install common, useful packages (e.g., dplyr, ggplot2, plotly) once, in your own user libraries. If 
you instead install these common packages into one of these kernels while you have it in-use, you will need to reinstall these common tools into each and every kernel you wish to use.

How to Stop using custom Kernels
--------------------------------
.. code-block:: bash
   ./icrn_manager libraries use none

This command undoes the behind-the-scenes updates of environment variables and returns your R environment to its default behavior.

All you have to do to restore the custom kernel usage is to leverage the 'use' command - see below.


List Available Libraries
------------------------
.. code-block:: bash

   ./icrn_manager libraries available

This command lists all available libraries and their versions in the central catalog.

Get an R Kernel
-------------
.. code-block:: bash

   ./icrn_manager libraries get <library> <version>

Example:

.. code-block:: bash

   ./icrn_manager libraries get pecan 1.9

This copies the identified kernel-version to your personal catalog, and unpacks it. It does not automatically use the kernel in your R environment.

Use an R Kernel
-------------
.. code-block:: bash

   ./icrn_manager libraries use <library> <version>

Example:

.. code-block:: bash

   ./icrn_manager libraries use pecan 1.9

This activates the specified kernel for your R session by automatically updating your ~/.Renviron file. Only one kernel can be activate at any time.

While this kernel is active, unless you specify otherwise, all R packages installed will be installed into this kernel. This enables you to augment this kernel with your own additions.

However, it also means that if you install new packages into this kernel, and then stop using this kernel, you will need to install those packages again the next time you want to use them.

If you have R packages you use regularly, it is recommended to install these into your base user libraries location, and once you have those common packages installed, begin using a custom kernel.

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

This command lists the libraries you have already checked out, which are ready for your immediate use.

Note that these libraries will not automatically update themselves. If it has been a long time since you've used a library, it is highly recommended to remove your own copy of it, clean your catalog, and check it out again.

Remove a Library
----------------
.. code-block:: bash

   ./icrn_manager libraries remove <library> <version>

Clean User Catalog Entry
------------------------
.. code-block:: bash

   ./icrn_manager libraries clean <library> <version>

This will scrub your catalog of the entries relating to this kernel and version. It will not alter any of the actual checked out files for these kernels.

You can use this command and omit the 'version' parameter to scrub all versions of a given library. 

This command, in conjunction with the 'remove' command, allows you to start from a clean-slate, if you wish to rebuild your personal catalog of kernels.

For more details on each command, see the :doc:`reference` section. 