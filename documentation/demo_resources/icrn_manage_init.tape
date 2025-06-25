# Where should we write the GIF?
Output icrn_manage_init.gif

# Set up a 1200x600 terminal with 46px font.
Set FontSize 18 
Set Width 1200
Set Height 600
Set WindowBar Colorful
Set TypingSpeed 20ms


Type "# User installation is simple; though the central repository must be pre-configured. "
Enter
Sleep 1s
Type `./icrn_manager libraries init ~/icrn_temp_repository`
Enter
Sleep 1s
Type "# ~/icrn_temp_repository should be changed to the ICRN central repository location"
Enter
Sleep 0.5s
Type "# User resources will be created if they do not exist."
Enter
Type "# Central resources will cause an error if they do not exist."
Sleep 10s
