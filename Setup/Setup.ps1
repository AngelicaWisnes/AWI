
# Timer-function for logging the time used for measuring execution-times
$sw = [Diagnostics.Stopwatch]::new()
$log = [System.Text.StringBuilder]::new()
function logTime {
  param( 
    [Parameter(Mandatory)][String]$timed,
    [bool]$restart = $true 
  )
  $sw.Stop()
  [void]$log.AppendFormat(" {1:0.000}s - {0}`n", $timed, $($sw.ElapsedMilliseconds / 1000))
  $sw.Reset()
  If ($restart) { $sw.Start() }
}


#################################################
###     Import relevant files and modules     ###
#################################################

$sw.Start()
. (Resolve-Path "$PSScriptRoot\CustomPrompt.ps1")
logTime "Import CustomPrompt"

. (Resolve-Path "$global:AWI/FunctionListGenerator/FunctionListGenerator.ps1")
logTime "Import FunctionListGenerator"

. (Resolve-Path "$global:AWI/Constants/Constants.ps1")
logTime "Import Constants"

. (Resolve-Path "$global:AWI/Functions/Functions.ps1")
logTime "Import Functions"

#. (Resolve-Path "$global:AWI/Installer/Installer.ps1")
#logTime "Import Installer"

. (Resolve-Path "$global:AWI/Logo/Logo.ps1")
logTime "Import Logo"

. (Resolve-Path "$global:AWI/SystemDependent/SystemDependentSetup.ps1")
logTime "Import SystemDependent"

# Import modules
if (!(Get-Module -ListAvailable -Name posh-git)) {
  Install-Module -Name posh-git
}
Import-Module -Name posh-git -ArgumentList @($false, $false, $true) # Arguments: [bool]$ForcePoshGitPrompt, [bool]$UseLegacyTabExpansion, [bool]$EnableProxyFunctionExpansion
logTime "Import Posh"


###############################
###      Initialization     ###
###############################

Initialize-FunctionListGenerator
logTime "Initialize ListGenerator"

Get-Logo
logTime "Get Logo"

Get-FunctionListInfo
logTime "Get FunctionListCommand"

Get-UpgradeListsInfo
logTime "Get UpgradeListCommand"

Get-DadJoke
logTime "Get DadJoke" -restart $false

# To show time-log: Uncomment the following line
# Write-Host -ForegroundColor Cyan $log.ToString()


#######################################
###      SETTINGS AND SHORTCUTS     ###
#######################################

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineKeyHandler -Chord Ctrl+1 -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('. ra')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+2 -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Get-Selfie')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

#function prompt {
#  # Your non-prompt logic here
#  #$prompt = Write-Prompt "Text before posh-git prompt " -ForegroundColor ([ConsoleColor]::Green)
#  if (Get-Module -ListAvailable -Name posh-git) { Get-Command $GitPromptScriptBlock } else { write-host "false" }
#
#  $prompt = Write-Prompt "`n"
#  
#  $prompt += & $GitPromptScriptBlock
#  #$prompt += "`n"
#  
#  $prompt.replace(">", "`n>")
#
#  #$prompt += Write-Prompt "Text after posh-git prompt" -ForegroundColor ([ConsoleColor]::Magenta)
#  if ($prompt) { "$prompt " } else { "FAIL > " }
#}
