
# How to install to PowerShell profile

- Place the root folder 'AWI' in the desired directory

- Run the batch-file 'ADD_TO_WINDOWS_PROFILE.bat'

**Note: This script will currently only work on windows**

### How it works:
- This batch-file will run the PowerShell-script 'Add_To_Windows_Profile.ps1'

- Said script will add an import-statement to the PowerShell-profile, referring to the main script-file in this repo: 'AWI.ps1' (See script-block below).
  - The script will first ask the user to confirm directory, then ask for specific confirmation before each following action
  - The user will be able to add the import-statement to their PowerShell 5 profile
  - The user will also be able to add the import-statement to their PowerShell 7 profile, as well as install PowerShell 7 if not already installed

```powershell
# Import AWI package
. <Full path to the AWI-root directory>\AWI.ps1
```