# Where should we write the GIF?
Output icrn_libraries_mngr_use_case.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set TypingSpeed 20ms

Type "# PEcAn - the Predictive Ecosystem Analyzer is an awesome R package, which i'm going to do something awesome with! 
Enter
Sleep 1s
Type "Rscript -e 'library(PEcAn.workflow)'"
Enter
Sleep 1s
Type "# oh, well, I guess not."
Enter
Sleep 3s
Type "# unless..."
Enter
Sleep 500ms
Type "./icrn_manager libraries list"
Sleep 500ms
Enter
Sleep 1s
Type "# it looks like i have this library available in my personal catalog!"
Enter
Sleep 1s

Type "# All I need to do is tell R to use it..."
Enter
Sleep 1s
# Type a command in the terminal.
Type "./icrn_manager libraries use pecan 1.9"
Sleep 500ms
Enter

Type "# Can I use PEcAn now?!"
Sleep 1s
Enter
Type "Rscript -e 'library(PEcAn.workflow)'"
Sleep 1s
Enter
Sleep 5s

