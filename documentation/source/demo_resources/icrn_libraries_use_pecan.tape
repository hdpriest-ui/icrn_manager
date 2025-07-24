# icrn_libraries_use_pecan.tape
# This file contains the commands used to generate the animated GIF demonstration
# of using the icrn_manager to get and use the pecan kernel

# Clear the terminal
clear

# Show the current directory
pwd

# List available kernels
./icrn_manager kernels available

# Get the pecan kernel
./icrn_manager kernels get R pecan 1.9

# List checked out kernels
./icrn_manager kernels list

# Use the pecan kernel
./icrn_manager kernels use R pecan 1.9

# Show the R environment
Rscript -e "cat('R library paths:\n'); cat(paste(.libPaths(), collapse='\n')); cat('\n\n')"

# Test the pecan kernel
Rscript -e "library(PEcAn.all)"

# Stop using the kernel
./icrn_manager kernels use none

# Show the R environment again
Rscript -e "cat('R library paths:\n'); cat(paste(.libPaths(), collapse='\n')); cat('\n\n')"

