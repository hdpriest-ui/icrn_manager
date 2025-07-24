# icrn_lib_manager_use_case.tape
# This file contains the commands used to generate the animated GIF demonstration
# of a complete use case workflow

# Clear the terminal
clear

# Show the current directory
pwd

# Initialize the manager
./icrn_manager kernels init /u/hdpriest/icrn_temp_repository

# List available kernels
./icrn_manager kernels available

# Get the cowsay kernel
./icrn_manager kernels get R cowsay 1.0

# List checked out kernels
./icrn_manager kernels list

# Use the cowsay kernel
./icrn_manager kernels use R cowsay 1.0

# Test the cowsay kernel
Rscript -e "library(cowsay); say('Hello from cowsay!')"

# Get the pecan kernel
./icrn_manager kernels get R pecan 1.9

# Switch to the pecan kernel
./icrn_manager kernels use R pecan 1.9

# Test the pecan kernel
Rscript -e "library(PEcAn.all)"

# Stop using any kernel
./icrn_manager kernels use none

# Show the R environment
Rscript -e "cat('R library paths:\n'); cat(paste(.libPaths(), collapse='\n')); cat('\n\n')"

