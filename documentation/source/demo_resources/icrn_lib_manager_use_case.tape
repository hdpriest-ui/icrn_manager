# Where should we write the GIF?
Output icrn_libraries_mngr_use_case.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set TypingSpeed 20ms

Type "# PEcAn - the Predictive Ecosystem Analyzer is a large, complex set of R packages. I want to use it."
Enter
Sleep 1s
Type "Rscript -e 'library(PEcAn.workflow)'"
Enter
Sleep 1s
Type "# I don't have this package installed. But the ICRN library manager lets me use it without installing it..."
Enter
Sleep 1s
Type "./icrn_manager libraries list"
Sleep 500ms
Enter
Sleep 1s
Type "# I have this library available in my personal catalog."
Enter
Sleep 1s
Type "# All I need to do is tell R to use it..."
Enter
Sleep 1s
# Type a command in the terminal.
Type "./icrn_manager libraries use pecan 1.9"
Sleep 500ms
Enter
Type "# And now I can use PEcAn"
Sleep 1s
Enter
Type "Rscript -e 'library(PEcAn.workflow)'"
Sleep 1s
Enter
Sleep 5s

