# Where should we write the GIF?
Output documentation/demo_resources/icrn_libraries_use_pecan.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set TypingSpeed 20ms

# Type a command in the terminal.
Type "# PEcAn is a large R library which takes hours to install..."
Enter
Sleep 1s
Type "# wait for it... (this takes about 4 minutes)"
Enter
Sleep 1s
Type "./icrn_manager libraries get pecan 1.9"
Enter
Sleep 240s
Type "# I've checked out this set of packages, now, i need to use it."
Enter
Sleep 1s
Type "./icrn_manager libraries use pecan 1.9"
Enter
Sleep 1s
Type "# I can now use pecan - without having to install it."
Enter
Sleep 1s
Type "Rscript -e 'library(PEcAn.workflow)'"
Enter
Sleep 10s

