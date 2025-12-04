# Creating R Libraries for the ICRN Manager

This directory contains resources for creating R libraries (kernels) for the Illinois Computes Library & Kernel Manager system.

## Overview

The ICRN Manager uses a hierarchical catalog structure organized by language (R, Python, etc.) to manage kernel environments. Each language contains multiple kernels, and each kernel can have multiple versions.

## Directory Structure

The central repository should be organized as follows:

```
central_repository/
├── icrn_kernel_catalog.json
├── R/
│   ├── cowsay/
│   │   └── 1.0/
│   │       └── R_cowsay.conda.pack.tar.gz
│   ├── pecan/
│   │   └── 1.9/
│   │       └── PEcAn-base-3.tar.gz
│   └── ...
├── Python/
│   ├── numpy/
│   │   └── 1.20/
│   │       └── python_numpy.conda.pack.tar.gz
│   └── ...
└── ...
```

## Catalog Structure

The `icrn_kernel_catalog.json` file should be located in the base repository directory and follow this structure:

```json
{
    "R": {
        "cowsay": {
            "1.0": {
                "conda-pack": "R_cowsay.conda.pack.tar.gz",
                "manifest": ""
            }
        },
        "pecan": {
            "1.9": {
                "conda-pack": "PEcAn-base-3.tar.gz",
                "manifest": ""
            }
        }
    },
    "Python": {
        "numpy": {
            "1.20": {
                "conda-pack": "python_numpy.conda.pack.tar.gz",
                "manifest": ""
            }
        }
    }
}
```

## Creating a New Kernel

1. **Create the conda environment**:
   ```bash
   conda create --solver=libmamba -c r -y -n R_mykernel r-base=4.4.2
   conda activate R_mykernel
   ```

2. **Install required packages**:
   ```bash
   Rscript -e 'install.packages(c("package1", "package2"), repos="http://cran.us.r-project.org")'
   ```

3. **Pack the environment**:
   ```bash
   conda install -y --solver=libmamba conda-pack
   conda pack -n R_mykernel -o ./R_mykernel.tar.gz
   ```

4. **Add to the catalog**:
   - Place the tarball in the appropriate language directory
   - Update the `icrn_kernel_catalog.json` file in the base repository directory with the new entry

## Example Catalog Files

- `example_icrn_catalogue.json`: Shows the old flat structure (for reference)
- `new_example_icrn_catalogue.json`: Shows the new hierarchical structure organized by language

## Testing

After adding a new kernel to the catalog, test it using:

```bash
./icrn_manager kernels get R mykernel 1.0
./icrn_manager kernels use R mykernel 1.0
```

For more detailed instructions, see the :doc:`maintainer_guide` section.
