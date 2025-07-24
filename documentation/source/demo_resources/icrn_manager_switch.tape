# icrn_manager_switch.tape
# This file contains the commands used to generate the animated GIF demonstration
# of switching between kernels

# Clear the terminal
clear

# Show the current directory
pwd

# List available kernels
./icrn_manager kernels available

# List checked out kernels
./icrn_manager kernels list

# Use the cowsay kernel
./icrn_manager kernels use R cowsay 1.0

# Test the cowsay kernel
Rscript -e "library(cowsay); say('Hello from cowsay!')"

# Switch to the pecan kernel
./icrn_manager kernels use R pecan 1.9

# Test the pecan kernel
Rscript -e "library(PEcAn.all)"

# Switch to the mixRF kernel
./icrn_manager kernels use R mixRF 1.0

# Test the mixRF kernel
Rscript -e "library(mixRF)"

# Stop using any kernel
./icrn_manager kernels use none

# Show the R environment
Rscript -e "cat('R library paths:\n'); cat(paste(.libPaths(), collapse='\n')); cat('\n\n')"
