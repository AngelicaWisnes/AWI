# Suppress 'unused-variable'-warning for this file
#[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()


################################################################
# NOTE: All variables should be specified in 'Check_Constants' #
################################################################

# Define Paths
$global:MY_POWERSHELL_5 = "EXAMPLE-VALUE:    Join-Path `"C:\Users\awi\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`" `"Windows PowerShell.lnk`""
$global:MY_POWERSHELL_7 = "EXAMPLE-VALUE:    Join-Path `"C:\Users\awi\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`" `"Windows PowerShell.lnk`""
$global:MY_POWERSHELL = $global:MY_POWERSHELL_5
If ($PSVersionTable.PSVersion.Major -eq 7) {
  $global:MY_POWERSHELL = $global:MY_POWERSHELL_7
}

$global:MY_BROWSER = "EXAMPLE-VALUE:    Join-Path `"C:\Users\awi\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`" `"Opera-nettleser.lnk`""

$global:MY_DOTNET_IDE = "EXAMPLE-VALUE:    Join-Path `"C:\Users\awi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code`" `"Visual Studio Code.lnk`""
$global:MY_JS_IDE = "EXAMPLE-VALUE:    Join-Path `"C:\Users\awi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code`" `"Visual Studio Code.lnk`""

$global:DEFAULT_START_PATH = "EXAMPLE-VALUE:    Resolve-Path `"C:\Users\awi\OneDrive\Development\Source`""


# Define other variables
$global:GIT_BRANCH_URL = 'https://github.com/AngelicaWisnes/{0}/branches'
