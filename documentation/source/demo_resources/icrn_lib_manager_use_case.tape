# Where should we write the GIF?
Output documentation/source/demo_resources/icrn_lib_manager_use_case.gif

# Set up a 1200x600 terminal with 18px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set WindowBar Colorful
Set TypingSpeed 20ms

# icrn_lib_manager_use_case.tape
# This file contains the commands used to generate the animated GIF demonstration
# of a complete use case workflow

Type "./icrn_manager kernels init /u/hdpriest/icrn_temp_repository"
Enter
Sleep 2s

Type "./icrn_manager kernels available"
Enter
Sleep 2s

Type "./icrn_manager kernels get R cowsay 1.0"
Enter
Sleep 180s

Type "./icrn_manager kernels list"
Enter
Sleep 2s

Type "./icrn_manager kernels use R cowsay 1.0"
Enter
Sleep 2s

Type "Rscript -e 'library(cowsay)'"
Enter
Sleep 2s

Type "./icrn_manager kernels get R pecan 1.9"
Enter
Sleep 180s

Type "./icrn_manager kernels use R pecan 1.9"
Enter
Sleep 2s

Type "Rscript -e 'library(PEcAn.all)'"
Enter
Sleep 2s

Type "./icrn_manager kernels use none"
Enter
Sleep 1s

Type "Rscript -e '.libPaths()'"
Enter
Sleep 2s

