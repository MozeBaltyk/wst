# Windows Local Settings

Scripts in this folder are automatically discovered and displayed
in the main menu under "Local Settings".


Rules:
- Must be safe to re-run
- Must not call `exit` but End with a clean return
- Must return control to menu.ps1
- Script starting with "_" are hidden from menu