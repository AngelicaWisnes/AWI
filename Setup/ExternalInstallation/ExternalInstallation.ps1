
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
  Write-Info ('Adding flag: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $flagName)
  $flagFilePath = Join-Path -Path $FLAG_PATH -ChildPath "$flagName.flag"
  If (Test-FlagExists -flagName $flagName) { Return Write-Success ('Flag already exists: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $flagName) }

  If (-Not (Test-FlagExists -flagName $flagName)) { New-Item -ItemType File -Path $flagFilePath -Force | Out-Null }
  If (Test-FlagExists -flagName $flagName) { Write-Success ('Successfully added flag: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $flagName) }
  Else { Write-Fail ('Failed to add flag: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $flagName) }
}

function Remove-Flag {
  param ([Parameter(Mandatory)][string]$flagName)
  Write-Info ('Removing flag: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $flagName)
  $flagFilePath = Join-Path -Path $FLAG_PATH -ChildPath "$flagName.flag"
  If (Test-FlagExists -flagName $flagName) { Remove-Item -Path $flagFilePath -Force }

  If (Test-FlagExists -flagName $flagName) { Write-Fail ('Failed to remove flag: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $flagName) }
  Else { Write-Success ('Successfully removed flag: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $flagName) }
}

function Set-FlagPath {
  If (-Not (Test-Path -Path $FLAG_PATH)) { New-Item -ItemType Directory -Path $FLAG_PATH -Force | Out-Null }
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
