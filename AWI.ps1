
Clear-Host

#$PSDefaultParameterValues = @{"Import-Module:UseWindowsPowerShell" = $false;}

$global:AWI = $PSScriptRoot
. $global:AWI\Setup\Setup.ps1

# Set start-path for PS-profile-reload. For a different start path, set the `$startPath variable in function 'ReloadPsProfile' and 'ReloadAWI'. 
If ($startPath) { Push-Location $startPath }
Else { Push-Location $global:DEFAULT_START_PATH -ErrorAction SilentlyContinue }
