# AWI PowerShell-package
 This package is a collection of my personal scripts, functions, aliases, and personalizations. Note that while I have tried to keep cross-platform compability in mind in some cases, my main focus has been a working solution on my own machines. Thus, non-windows platforms may experience issues with some of the content of this repo.

 ### Content
-  The subfolder "Installer" with its subcontent is somewhat outside the rest of the repo's functionality. This is only intended as a utility for installing the AWI-package to your PowerShell profile. More details on how this works, is further described in the [Installer-README](./Installer/README.md) inside the folder.

- The subfolder "Constants" contains various global constants that are independent from the system.

- The subfolder "Functions" contains a set of functions sorted by their category into separate files, as well as a FunctionListGenerator whose function is to print out a formatted list of relevant functions.

- The subfolder "Logo" contains some of my own images, as well as some ascii-art generators / -converters to print a header when starting a PowerShell session.

- The subfolder "Setup" takes care of the importing of all relevant main-files, as well as configuring some PowerShell funcionality such as some keybindings and personal prompt.

- Finally the AWI.ps1 is the main file which acts as the entrance to the AWI-package.

 ### How to install
 - Clone the repo to your local machine and place it in your desired directory

 - See the [Installer-README](./Installer/README.md) for how to add to your PowerShell profile

 - Every time a PowerShell session running the AWI-package is started, there will be a quick check in the [SystemDependentSetup](./SystemDependent/SystemDependentSetup.ps1) if your system-dependent files are created.

   - If the files are not created, these will automatically be created based on the Template-folder

   - Then it will check that all required system-dependent paths are implemented and valid. If not, you will get a prompt asking you to add the required paths. 
 