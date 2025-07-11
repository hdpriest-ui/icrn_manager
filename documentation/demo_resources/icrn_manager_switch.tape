# Where should we write the GIF?
Output documentation/demo_resources/icrn_libraries_mngr_switch.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set TypingSpeed 20ms

Type "# I am currently using PEcAn, and I want to use Bioconductor."
Enter
Sleep 1s
Type "Rscript -e 'library(PEcAn.workflow)'"
Enter
Sleep 1s
Type "Rscript -e 'library(edgeR)'"
Enter
Sleep 1s
Type "# As long as I have them checked out, I can switch between kernels easily." 
Enter
Sleep 1s
Type "./icrn_manager libraries list"
Sleep 500ms
Enter
Sleep 1s
# Type a command in the terminal.
Type "./icrn_manager libraries use Rbioconductor 3.20"
Sleep 500ms
Enter
Type "Rscript -e 'library(edgeR)'"
Sleep 1s
Enter
Sleep 5s
Type "# Now I can use Bioconductor, but not PEcAn."
Sleep 1s
Enter
Type "Rscript -e 'library(PEcAn.workflow)'"
Enter
Sleep 5s
