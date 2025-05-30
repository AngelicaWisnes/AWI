
$wingetAppIDs = @(
  'Spotify.Spotify',
  'Microsoft.VisualStudioCode',
  'Microsoft.PowerToys',
  'Logitech.OptionsPlus',
  'SlackTechnologies.Slack',
  'JetBrains.Toolbox',
  'Git.Git',
  'OpenJS.NodeJS.LTS'
)


function Install-AppFromWinget {
  param([Parameter(Mandatory)][String]$appID)
  $psScriptBlock = [scriptblock]::Create("winget install --id '$appID'")

  Write-Initiate ('Winget install --id {0}' -f (color_focus $appID))
  If ($(Confirm-Action -Prompt "Installing $appID - Do you want to proceed?")) {
    $ps5Process = Start-Process powershell -ArgumentList '-NoProfile', '-Command', $psScriptBlock -PassThru
    $ps5Process.WaitForExit()
  }

  If (Test-AppIsInstalled -appID $appID) {
    Write-Success ('Finished installing {0}' -f (color_focus $appID))
    Return $true
  }
  Else {
    Write-Fail ('Failed installing {0}' -f (color_focus $appID))
    Return $false
  }
}


function Test-AppIsInstalled {
  param([Parameter(Mandatory)][String]$appID)
  $private:app = winget list --id $appID 2>&1

  If ( $private:app -match 'No installed package found') {
    Write-Info ('Is not installed: {0}' -f (color_focus $appID))
    Return $false
  }
  
  $flagName = Get-WingetFlagNameByAppID -appID $appID
  Write-Info ('Is installed: {0}' -f (color_focus $appID))
  Add-Flag -flagName $flagName
  Return $true
}


function Test-AppShouldBeInstalled {
  param([Parameter(Mandatory)][String]$appID)
  $flagName = Get-WingetFlagNameByAppID -appID $appID

  Write-Info ('Checking - Should {0}{1} be installed' -f (color_focus $appID), $Global:RGB_INFO.fg)

  If ($(Test-AppIsInstalled -appID $appID) -or $(Test-FlagExists -flagName $flagName)) {
    Write-Info ('Finished - Checking: {0}{1} should NOT be installed' -f (color_focus $appID), $Global:RGB_INFO.fg)
    Return $false
  }
  
  Write-Info ('Finished - Checking: {0}{1} should be installed' -f (color_focus $appID), $Global:RGBs.Green.fg)
  Return $true
}


function Test-AllAppsAreInstalled {
  foreach ($appID in $wingetAppIDs) {
    $flagName = Get-WingetFlagNameByAppID -appID $appID
    If (-not (Test-FlagExists -flagName $flagName)) { Return $false }
  }
  Return $true
}


function Get-WingetFlagNameByAppID {
  param([Parameter(Mandatory)][String]$appID)
  Return "winget-install-$($appID -replace '\.', '-')"
}


function Install-Apps {
  Write-Initiate 'Winget app installation'
  
  foreach ($appID in $wingetAppIDs) {
    Write-Initiate ('Installing-procedure: {0}' -f (color_focus 'appID'))

    $flagName = Get-WingetFlagNameByAppID -appID $appID
    If (-not $(Test-AppShouldBeInstalled -appID $appID)) { continue }
    $installed = Install-AppFromWinget -appID $appID

    If (-not $installed) {
      Write-Fail ('Did not install {0}' -f (color_focus $appID))
      Write-Info ('Running this function again will by default attempt to install {0}{1} again. ' -f (color_focus $appID), $Global:RGB_INFO.fg)
      If (-not $(Confirm-Action -Prompt 'Do you want to add a flag to prevent that?')) { continue }
    }
    Else { Write-Success ('Successfully installed {0}' -f (color_focus $appID)) }

    Add-Flag -flagName $flagName
    Write-Success ('Finished procedure: {0}' -f (color_focus $appID))
  }

  Write-Success 'Finished winget app installation'
}


function Invoke-ExternalAppInstaller {
  $flagName = 'external-app-installer'
  If (Test-FlagExists -flagName $flagName) { Return }
  If (Confirm-Action -Prompt 'Do you want to run the external app installer?') { Install-Apps }

  Write-Info 'Checking - Have all apps been installed'
  If (Test-AllAppsAreInstalled) {
    Write-Success 'All apps have been installed. Adding flag to prevent future running of external app installer'
    Add-Flag -flagName $flagName
  }
  Else {
    Write-Fail 'All apps have not been installed'
    If (Confirm-Action -Prompt 'Do you want to prevent running the external app installer again?') { Add-Flag -flagName $flagName }
  }
}
Add-ToFunctionList -category 'Setup' -name 'Invoke-ExternalAppInstaller' -value 'Selectively install apps using winget'
