# Where should we write the GIF?
Output documentation/source/demo_resources/icrn_libraries.gif

# Set up a 1200x600 terminal with 18px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set WindowBar Colorful
Set TypingSpeed 20ms

# icrn_libraries.tape
# This file contains the commands used to generate the animated GIF demonstration
# of listing available kernels

Type "./icrn_manager kernels available"
Enter
Sleep 2s

Type "./icrn_manager kernels list"
Enter
Sleep 2s
