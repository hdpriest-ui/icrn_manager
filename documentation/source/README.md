# Illinois Computes Library & Kernel Manager Documentation

This folder contains the Sphinx/reStructuredText documentation source for the Illinois Computes Library & Kernel Manager, suitable for publishing on Read the Docs or similar platforms.

## Building the Documentation Locally

1. Install Sphinx and dependencies:
   ```sh
   pip install -r requirements.txt
   ```
2. Build the HTML documentation:
   ```sh
   make html
   ```
3. Open `_build/html/index.html` in your browser to preview.

## Structure
- `index.rst`: Main entry point
- `overview.rst`, `installation.rst`, etc.: Section content
- `conf.py`: Sphinx configuration
- `Makefile`: Build commands

For more, see the published docs or contribute improvements! 