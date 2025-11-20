# Welcome to the ICRN Kernel Manager

## What is the ICRN Kernel Manager?
The Illinois Computes Research Notebook (ICRN) enables students and researchers to access computing at scale via an easily accessible web interface. But, many scientific domains rely on a wide array of complex packages for R and Python which are not easy to install. It is common for new users of compute systems to spend hours attempting to configure their environments.

The ICRN Kernel Manager aims to eliminate this barrier.

<img src="documentation/demo_resources/icrn_libraries_mngr_use_case_cowsay.gif" align="center" width="600"/>


## User Installation
```sh
./icrn_manager kernels init <path to central repository>
```
Example for development work:
```sh
./icrn_manager kernels init /u/hdpriest/icrn_temp_repository
```
<img src="documentation/demo_resources/icrn_manage_init.gif" align="center" width="600"/>

This command can be run again to point at a different central repository, without disrupting the user's files.

## Usage
The ICRN Kernel Manager has all familiar operations for listing, getting, and using entites from a catalog or repository of kernel packages organized by language:

### Available Packages in the Catalog
```sh
./icrn_manager kernels available
```
This command interrogates the central catalog of available packages, and lists them out, organized by language with their various versions.

You can check out more than one version of each package set at a time, but you can only use one package set at any time.
```sh
Available kernels in ICRN catalog (/u/hdpriest/icrn_temp_repository/icrn_kernel_catalog.json):
Language	Kernel	Version
R	cowsay	1.0
R	mixRF	1.0
R	pecan	1.9
R	vctrs	1.0
Python	numpy	1.20
```
Alias:
```sh
./icrn_manager kernels avail
```

### Get a package set
```sh
./icrn_manager kernels get <language> <kernel> <version>
```
Example:
```sh
./icrn_manager kernels get R cowsay 1.0
./icrn_manager kernels get Python numpy 1.24.0
```
This command obtains the correct environment from the central repository, unpacks it, identifies the location of the packages, and updates the user's catalogue with this information.

```sh
./icrn_manager kernels get R cowsay 1.0
Desired kernel:
Language: R
Kernel: cowsay
Version: 1.0

ICRN Catalog:
/u/hdpriest/icrn_temp_repository/icrn_kernel_catalog.json
User Catalog:
/u/hdpriest/.icrn/icrn_kernels/user_catalog.json

Making target directory: /u/hdpriest/.icrn/icrn_kernels/cowsay-1.0/
Checking out kernel...
checking for: /u/hdpriest/.icrn/icrn_kernels/cowsay-1.0//bin/activate
activating environment
doing unpack
getting R path.
determined: /u/hdpriest/.icrn/icrn_kernels/cowsay-1.0/lib/R/library
deactivating
Updating user's catalog with R cowsay and 1.0
Done.

Be sure to call "./icrn_manager kernels use R cowsay 1.0" to begin using this kernel in R.
```

### Use a package set
```sh
./icrn_manager kernels use <language> <kernel> <version>
```
Example:
```sh
./icrn_manager kernels use R cowsay 1.0
./icrn_manager kernels use Python numpy 1.24.0
```
<img src="documentation/demo_resources/icrn_libraries_mngr_simple_use_cowsay.gif" align="center" width="600"/>

```sh
./icrn_manager kernels use R cowsay 1.0
Desired kernel:
Language: R
Kernel: cowsay
Version: 1.0
checking for: /u/hdpriest/.icrn/icrn_kernels/r/cowsay-1.0/lib/R/library
Found existing link; removing...

./icrn_manager kernels use Python numpy 1.24.0
Desired kernel:
Language: Python
Kernel: numpy
Version: 1.24.0
Found. Activating Python kernel...
Installing Python kernel: numpy-1.24.0
Python kernel installation complete.
Kernel 'numpy-1.24.0' is now available in Jupyter.
/u/hdpriest/.icrn/icrn_kernels/cowsay
Found. Linking and Activating...
Using /u/hdpriest/.icrn_b/icrn_kernels/cowsay within R...
Done.

```
This command updates the user's ```~{HOME}/.Renviron``` file with the location of the indicated kernel. Only one package-set can be 'in-use' at any time. Package-sets can be switched without 'get'ing them again.

Note that the user doesn't have to download, install, or compile any R packages at all. 

### Switch to a different set of packages
```sh
./icrn_manager kernels use R pecan 1.9
```

### Stop using package sets
```sh
./icrn_manager kernels use none
```

## Implementation Details

### Testing
The project includes a comprehensive test suite to ensure reliability and code quality:

```sh
# Run all tests
./tests/run_tests.sh all

# Run specific test categories
./tests/run_tests.sh kernels          # Kernel operations
./tests/run_tests.sh update_r_libs    # R library management  
./tests/run_tests.sh config           # Configuration validation
./tests/run_tests.sh help             # Help and basic commands
./tests/run_tests.sh kernel_indexer   # Kernel indexing and collation
```

**Test Features:**
- **Isolated Environments**: Each test runs independently to prevent interference
- **Mock Data**: Tests use consistent mock kernel packages and catalogs
- **Error Handling**: Comprehensive testing of both success and failure scenarios
- **Continuous Integration**: Automated testing on all pull requests

**Recent Improvements:**
- Enhanced error handling with clear, descriptive error messages
- File path validation to prevent silent failures
- Improved test isolation for more reliable testing
- Better permission checking and validation

For detailed testing information, see the [Contributing Guide](documentation/source/contributing.rst).

### TODO
- save all config paths into the configure json, so they can be commonly shared across shell scripts
- add in a admin-configure readme, for setting up the central repo structure
    - better yet, add in a shell script that does this
- add in a 'kernels' subcommand for ipykernel support methods
- add in a {HOME}/.icrn_trash location to move old packages
