
##########################
# Flag-handler functions #
##########################

$Global:FLAG_PATH = Join-Path $PSScriptRoot 'Flags'

function Test-FlagExists {
  param ([Parameter(Mandatory)][string]$flagName)
  $flagFilePath = Join-Path -Path $FLAG_PATH -ChildPath "$flagName.flag"
  Return Test-Path -Path $flagFilePath
}

function Add-Flag {
  param ([Parameter(Mandatory)][string]$flagName)
  OUT $(PE -txt:"Adding flag: $flagName" -fg:$Global:colors.Cyan)
  $flagFilePath = Join-Path -Path $FLAG_PATH -ChildPath "$flagName.flag"
  if (Test-FlagExists -flagName $flagName) { Return OUT $(PE -txt:"Flag already exists: $flagName" -fg:$Global:colors.Green) }

  if (-Not (Test-FlagExists -flagName $flagName)) { New-Item -ItemType File -Path $flagFilePath -Force | Out-Null }
  if (Test-FlagExists -flagName $flagName) { OUT $(PE -txt:"Successfully added flag: $flagName" -fg:$Global:colors.Green) }
  else { OUT $(PE -txt:"Failed to add flag: $flagName" -fg:$Global:colors.Red) }
}

function Remove-Flag {
  param ([Parameter(Mandatory)][string]$flagName)
  OUT $(PE -txt:"Removing flag: $flagName" -fg:$Global:colors.Cyan)
  $flagFilePath = Join-Path -Path $FLAG_PATH -ChildPath "$flagName.flag"
  if (Test-FlagExists -flagName $flagName) { Remove-Item -Path $flagFilePath -Force }

  if (Test-FlagExists -flagName $flagName) { OUT $(PE -txt:"Failed to remove flag: $flagName" -fg:$Global:colors.Red) }
  else { OUT $(PE -txt:"Successfully removed flag: $flagName" -fg:$Global:colors.Green) }
}

function Set-FlagPath {
  if (-Not (Test-Path -Path $FLAG_PATH)) { New-Item -ItemType Directory -Path $FLAG_PATH -Force | Out-Null }
}


########################################
# Import external installation scripts #
########################################

. (Resolve-Path "$PSScriptRoot\Installers\AppInstaller.ps1")
. (Resolve-Path "$PSScriptRoot\Installers\ModuleInstaller.ps1")
. (Resolve-Path "$PSScriptRoot\VSCode\VSCodeSetup.ps1")


function Remove-Flags {
  $flags = Get-ChildItem -Path $Global:SYSTEM_FLAGS_PATH -Filter '*.flag' -Recurse
  $flags | ForEach-Object {
    $flagName = $_.BaseName
    If (Confirm-Action -Prompt "Removing flag: $flagName") { Remove-Flag -flagName $flagName }
  }
}
Add-ToFunctionList -category 'Setup' -name 'Remove-Flags' -value 'Selectively remove flags from the system'


#################################################
# Set flag-path and run the external installers #
#################################################

Set-FlagPath
Invoke-ExternalAppInstaller
