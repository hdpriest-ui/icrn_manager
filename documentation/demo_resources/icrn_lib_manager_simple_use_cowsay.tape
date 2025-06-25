# Where should we write the GIF?
Output icrn_libraries_mngr_simple_use_cowsay.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set WindowBar Colorful
Set TypingSpeed 20ms


Type "# To use a library that has already been pulled from the central catalog, simply 'use' it: 
Enter
Sleep 1s
Type "./icrn_manager libraries list"
Sleep 500ms
Enter
Sleep 1s
Type "./icrn_manager libraries use cowsay 1.0"
Sleep 500ms
Enter

Type "# R can now see the cowsay packages, all dependencies, and any binaries installed alongside"
Sleep 1s
Enter
Type `Rscript -e 'library(cowsay)' -e 'say("Be not afraid.")'`
Sleep 1s
Enter
Type ""
Enter
Sleep 10s