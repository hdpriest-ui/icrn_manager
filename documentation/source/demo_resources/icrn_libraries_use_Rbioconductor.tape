# Where should we write the GIF?
Output documentation/source/demo_resources/icrn_libraries_use_Rbioconductor.gif

# Set up a 1200x600 terminal with 18px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set WindowBar Colorful
Set TypingSpeed 20ms

# icrn_libraries_use_Rbioconductor.tape
# This file contains the commands used to generate the animated GIF demonstration
# of using the icrn_manager to get and use the Rbioconductor kernel

Type "./icrn_manager kernels available"
Enter
Sleep 2s

Type "./icrn_manager kernels get R Rbioconductor 3.20"
Enter
Sleep 180s

Type "./icrn_manager kernels list"
Enter
Sleep 2s

Type "./icrn_manager kernels use R Rbioconductor 3.20"
Enter
Sleep 2s

Type "Rscript -e '.libPaths()'"
Enter
Sleep 2s

Type "Rscript -e 'BiocManager::version()'"
Enter
Sleep 2s

Type "Rscript -e 'library(edgeR)'"
Enter
Sleep 2s

Type "./icrn_manager kernels use none"
Enter
Sleep 1s

Type "Rscript -e '.libPaths()'"
Enter
Sleep 2s

