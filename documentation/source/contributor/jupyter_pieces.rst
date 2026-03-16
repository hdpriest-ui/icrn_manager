How Python Kernels Work in JupyterHub
=====================================

This page describes the internal mechanics of Python kernel registration for
developers working on or extending ``icrn_manager``.

Overview
--------

Activating a Python kernel is a two-step process:

1. **Get** — register the kernel's conda environment path in the user catalog.
2. **Use** — install a Jupyter kernelspec from that environment so JupyterHub
   can discover it.

These steps are intentionally separate so that users can check out kernels
without immediately activating them, and can switch between activated kernels
without re-fetching from the central repository.

Step 1: ``kernels get`` — Registering the environment
------------------------------------------------------

.. code-block:: bash

   icrn_manager kernels get Python <kernel_name> <version>

This calls ``kernels__get_in_place()``, which:

1. Reads ``environment_location`` for the requested kernel from the central
   catalog (``icrn_kernel_catalog.json``).
2. Validates that ``$environment_location/bin/activate`` exists, confirming
   the path points to a conda environment.
3. Writes the path into the user catalog (``~/.icrn/icrn_kernels/user_catalog.json``)
   under the key ``Python.<kernel_name>.<version>.absolute_path``.

The kernel's conda environment is **not copied or relocated** — ``absolute_path``
points directly into the central repository. The user catalog entry is simply
a record of which central environments the user has registered.

Central catalog entry format (``icrn_kernel_catalog.json``):

.. code-block:: json

   {
     "Python": {
       "astro": {
         "1.0": {
           "environment_location": "/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/Python/astro/1.0"
         }
       }
     }
   }

User catalog entry written by ``get``:

.. code-block:: json

   {
     "Python": {
       "astro": {
         "1.0": {
           "absolute_path": "/sw/icrn/jupyter/icrn_ncsa_resources/Kernels/Python/astro/1.0"
         }
       }
     }
   }

Step 2: ``kernels use`` — Installing the kernelspec
----------------------------------------------------

.. code-block:: bash

   icrn_manager kernels use Python <kernel_name> <version>

This calls ``kernels__use()``, which:

1. Reads ``absolute_path`` from the user catalog for the requested kernel.
2. Checks whether a kernelspec named ``<kernel_name>-<version>`` is already
   installed (via ``jupyter kernelspec list``) and removes it if so.
3. Sources ``$absolute_path/bin/activate`` to enter the conda environment.
4. Runs ``python -m ipykernel install --user --name <kernel_name>-<version>``
   to write a kernelspec into ``~/.local/share/jupyter/kernels/``.
5. Deactivates the environment.

JupyterHub discovers kernelspecs from ``~/.local/share/jupyter/kernels/`` at
session start. Once the kernelspec is installed, the kernel appears in the
notebook kernel picker with the display name ``<kernel_name> <version>``.

.. note::
   The conda environment **must have** ``ipykernel`` installed. If it is
   missing, the ``python -m ipykernel install`` step will fail with a
   non-zero exit code and ``icrn_manager`` will report an error. Ensure
   ``ipykernel`` is included when building any Python kernel environment.

Deactivating kernels
--------------------

.. code-block:: bash

   icrn_manager kernels use Python none

Passing ``none`` as the kernel name removes all Python kernelspecs that are
present in both the user catalog and ``jupyter kernelspec list``. Kernelspecs
not tracked in the user catalog are left untouched.

Kernel naming convention
------------------------

The Jupyter kernelspec name is always ``<kernel_name>-<version>`` (e.g.
``astro-1.0``). This is also the identifier used in ``jupyter kernelspec
list`` and the directory name under ``~/.local/share/jupyter/kernels/``.

The display name shown in the JupyterHub UI is ``<kernel_name> <version>``
(space-separated, e.g. ``astro 1.0``).

Requirements for a valid Python kernel environment
---------------------------------------------------

For a conda environment to be usable as an ICRN Python kernel it must:

- Be a conda environment with a ``bin/activate`` script (used by ``get`` to
  validate the path and by ``use`` to enter the environment).
- Have ``ipykernel`` installed (required for ``python -m ipykernel install``).
- Be accessible at the path recorded in ``environment_location`` in the
  central catalog.
