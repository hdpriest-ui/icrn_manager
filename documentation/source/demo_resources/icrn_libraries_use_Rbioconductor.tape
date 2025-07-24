# icrn_libraries_use_Rbioconductor.tape
# This file contains the commands used to generate the animated GIF demonstration
# of using the icrn_manager to get and use the Rbioconductor kernel

# Clear the terminal
clear

# Show the current directory
pwd

# List available kernels
./icrn_manager kernels available

# Get the Rbioconductor kernel
./icrn_manager kernels get R Rbioconductor 3.20

# List checked out kernels
./icrn_manager kernels list

# Use the Rbioconductor kernel
./icrn_manager kernels use R Rbioconductor 3.20

# Show the R environment
Rscript -e "cat('R library paths:\n'); cat(paste(.libPaths(), collapse='\n')); cat('\n\n')"

# Test the Rbioconductor kernel
Rscript -e "BiocManager::version()"

# Test loading a bioconductor package
Rscript -e "library(edgeR)"

# Stop using the kernel
./icrn_manager kernels use none

# Show the R environment again
Rscript -e "cat('R library paths:\n'); cat(paste(.libPaths(), collapse='\n')); cat('\n\n')"

