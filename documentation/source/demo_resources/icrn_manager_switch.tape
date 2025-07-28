# Where should we write the GIF?
Output documentation/source/demo_resources/icrn_manager_switch.gif

# Set up a 1200x600 terminal with 18px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set WindowBar Colorful
Set TypingSpeed 20ms

# icrn_manager_switch.tape
# This file contains the commands used to generate the animated GIF demonstration
# of switching between kernels

Type "./icrn_manager kernels available"
Enter
Sleep 2s

Type "./icrn_manager kernels list"
Enter
Sleep 2s

Type "./icrn_manager kernels use R cowsay 1.0"
Enter
Sleep 2s

Type "Rscript -e 'library(cowsay)'"
Enter
Sleep 2s

Type "./icrn_manager kernels use R pecan 1.9"
Enter
Sleep 2s

Type "Rscript -e 'library(PEcAn.all)'"
Enter
Sleep 2s

Type "./icrn_manager kernels use R mixRF 1.0"
Enter
Sleep 2s

Type "Rscript -e 'library(mixRF)'"
Enter
Sleep 2s

Type "./icrn_manager kernels use none"
Enter
Sleep 1s

Type "Rscript -e '.libPaths()'"
Enter
Sleep 2s
