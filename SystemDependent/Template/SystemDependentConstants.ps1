# Suppress 'unused-variable'-warning for this file
#[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()


################################################################
# NOTE: All variables should be specified in 'Check_Constants' #
################################################################

# Define Paths
$global:MY_POWERSHELL_5 = "EXPAMPLE-VALUE:    Join-Path `"C:\Users\roger\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`" `"Windows PowerShell.lnk`""
$global:MY_POWERSHELL_7 = "EXPAMPLE-VALUE:    Join-Path `"C:\Users\roger\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`" `"Windows PowerShell.lnk`""
$global:MY_POWERSHELL = $global:MY_POWERSHELL_5
if ($PSVersionTable.PSVersion.Major -eq 7) {
    $global:MY_POWERSHELL = $global:MY_POWERSHELL_7
}

$global:MY_BROWSER = "EXPAMPLE-VALUE:    Join-Path `"C:\Users\roger\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`" `"Opera-nettleser.lnk`""

$global:MY_DOTNET_IDE = "EXPAMPLE-VALUE:    Join-Path `"C:\Users\roger\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code`" `"Visual Studio Code.lnk`""
$global:MY_JS_IDE = "EXPAMPLE-VALUE:    Join-Path `"C:\Users\roger\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Visual Studio Code`" `"Visual Studio Code.lnk`""

$global:DEFAULT_START_PATH = "EXPAMPLE-VALUE:    Resolve-Path `"C:\Users\roger\OneDrive\Development\Source`""


# Define other variables
$global:GIT_BRANCH_URL = "https://github.com/RogerWisnes/{0}/branches"
