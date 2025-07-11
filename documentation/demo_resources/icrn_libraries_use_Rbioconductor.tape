# Where should we write the GIF?
Output documentation/demo_resources/icrn_libraries_use_Rbioconductor.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set TypingSpeed 20ms

# Type a command in the terminal.
Type "# RBioconductor is a very large R library which can take hours to install..."
Enter
Sleep 1s
Type "./icrn_manager libraries get Rbioconductor 3.20"
Enter
Sleep 1s
Type "# wait for it... (this takes about a few minutes)"
Enter
Sleep 240s
Type "# I've checked out this R kernel, now, i need to use it."
Enter
Sleep 1s
Type "./icrn_manager libraries use Rbioconductor 3.20"
Enter
Sleep 1s
Type "# Just like that - I can use Rbioconductor"
Enter
Sleep 1s
Type "Rscript -e 'library(BiocManager)'"
Enter
Sleep 2s
Type "Rscript -e 'library(edgeR)'"
Enter
Sleep 2s

