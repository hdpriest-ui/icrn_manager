# Welcome to the ICRN Library Manager

## What is the ICRN Library Manager?
The Illinois Computes Research Notebook (ICRN) enables students and researchers to access computing at scale via an easily accessible web interface. But, many scientific domains rely on a wide array of complex packages for R and Python which are not easy to install. It is common for new users of compute systems to spend hours attempting to configure their environments.

The ICRN Library Manager aims to eliminate this barrier.

<img src="documentation/demo_resources/icrn_libraries_mngr_use_case_cowsay.gif" align="center" width="600"/>


## User Installation
```sh
./icrn_manager libraries init <path to central repository>
```
Example for development work:
```sh
./icrn_manager libraries init /u/hdpriest/icrn_temp_repository
```
<img src="documentation/demo_resources/icrn_manage_init.gif" align="center" width="600"/>

This command can be run again to point at a different central repository, without disrupting the user's files.

## Usage
The ICRN Library Manager has all familiar operations for listing, getting, and using entites from a catalog or repository of library packages:

### Available Packages in the Catalog
```sh
./icrn_manager libraries available
```
This command interrogates the central catalog of available packages, and lists them out, with their various versions.

You can check out more than one version of each package set at a time, but you can only use one package set at any time.
```sh
Available libraries in ICRN catalog (/u/hdpriest/icrn_temp_repository/r_libraries/icrn_catalogue.json):
Library Version
cowsay  1.0
mixRF   1.0
pecan   1.9
vctrs   1.0
```
Alias:
```sh
./icrn_manager libraries avail
```

### Get a package set
```sh
./icrn_manager libraries get cowsay 1.0
```
This command obtains the correct environment from the central repository, unpacks it, identifies the location of the R packages, and updates the user's catalogue with this information.

```sh
./icrn_manager libraries get cowsay 1.0
Desired library:
Library: cowsay
Version: 1.0

ICRN Catalog:
/u/hdpriest/icrn_temp_repository/r_libraries/icrn_catalogue.json
User Catalog:
/u/hdpriest/.icrn/icrn_libraries/user_catalog.json

Making target directory: /u/hdpriest/.icrn/icrn_libraries/cowsay-1.0/
Checking out library...
checking for: /u/hdpriest/.icrn/icrn_libraries/cowsay-1.0//bin/activate
activating environment
doing unpack
getting R path.
determined: /u/hdpriest/.icrn/icrn_libraries/cowsay-1.0/lib/R/library
deactivating
Updating user's catalog with cowsay and 1.0
Done.

Be sure to call "./icrn_manager libraries use cowsay 1.0" to begin using this library in R.
```

### Use a package set
```sh
./icrn_manager libraries use cowsay 1.0
```
<img src="documentation/demo_resources/icrn_libraries_mngr_simple_use_cowsay.gif" align="center" width="600"/>

```sh
./icrn_manager libraries use cowsay 1.0
Desired library:
Library: cowsay
Version: 1.0
checking for: /u/hdpriest/.icrn/icrn_libraries/cowsay-1.0/lib/R/library
Found existing link; removing...
/u/hdpriest/.icrn/icrn_libraries/cowsay
Found. Linking and Activating...
Using /u/hdpriest/.icrn_b/icrn_libraries/cowsay within R...
Done.

```
This command updates the user's ```~{HOME}/.Renviron``` file with the location of the indicated library. Only one package-set can be 'in-use' at any time. Package-sets can be switched without 'get'ing them again.

Note that the user doesn't have to download, install, or compile any R packages at all. 

### Switch to a different set of packages
```sh
./icrn_manager libraries use pecan 1.9
```

### Stop using package sets
```sh
./icrn_manager libraries use none
```

## Implementation Details


### TODO
- save all config paths into the configure json, so they can be commonly shared across shell scripts
- add in a admin-configure readme, for setting up the central repo structure
    - better yet, add in a shell script that does this
- add in a 'kernels' subcommand for ipykernel support methods
- add in a {HOME}/.icrn_trash location to move old packages