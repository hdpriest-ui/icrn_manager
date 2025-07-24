Contributing
============

We welcome contributions to the Illinois Computes Library & Kernel Manager project!

The source code and latest updates are available on GitHub: `hdpriest-ui/icrn_manager <https://github.com/hdpriest-ui/icrn_manager>`

Developer Guide: Creating New Kernels
-------------------------------------
- To contribute new R kernels (library environments) to the central catalog, see :doc:`maintainer_guide` for a step-by-step walkthrough using Bioconductor as an example.

Development Environment
-----------------------
The project includes a Docker development environment that mimics the NCSA ICRN JupyterHub environment:

- **Docker Setup**: See `.github/docker/Rstudio/Dockerfile` for the complete development environment
- **Automated Builds**: GitHub Actions automatically builds and pushes Docker images to the GitHub Container Registry
- **Dependencies**: The Docker image includes R, RStudio, jq, and all necessary tools for testing icrn_manager

To use the development environment:

.. code-block:: bash

   # Pull the latest image
   docker pull ghcr.io/hdpriest-ui/icrn_manager:latest
   
   # Run the container
   docker run -it ghcr.io/hdpriest-ui/icrn_manager:latest

The icrn_manager tools are automatically available in the container's PATH.

How to Contribute
-----------------
- Report bugs or request features via the issue tracker.
- Submit pull requests for code or documentation improvements.
- Propose enhancements to the documentation site.

Improving Documentation
----------------------
- Edit or add reStructuredText (.rst) files in the documentation/icrn_manager_docs/ directory.
- Follow Sphinx and Read the Docs best practices for structure and formatting.
- Preview your changes locally before submitting a pull request.

Code Contributions
------------------
- Fork the repository and create a feature branch.
- Follow the existing code style and add comments where helpful.
- Test your changes before submitting a pull request.
- The GitHub Actions workflow will automatically test your changes in the Docker environment.

Thank you for helping improve the Illinois Computes Library & Kernel Manager! 