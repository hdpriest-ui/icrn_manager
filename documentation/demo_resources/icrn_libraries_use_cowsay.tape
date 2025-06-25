# Where should we write the GIF?
Output icrn_libraries_use_pecan.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600

# Type a command in the terminal.
Type "./icrn_manager libraries use pecan 1.9"

# Pause for dramatic effect...
Sleep 500ms

# Run the command by pressing enter.
Enter

Type "# we now have instructed R to use the library location containing pecan 1.9
Enter
# Admire the output for a bit.
Sleep 5s

Type "# we can prove this by asking R what its libPaths content is:
Sleep 1s
Type "Rscript -e '.libPaths()'"
Sleep 1s
Enter

Type "# we can further prove this by asking R to load a pecan package within R..."
Sleep 1s
Enter
Type "Rscript -e 'library(PEcAn.workflow)'"
Sleep 3s
Enter
Sleep 3s

