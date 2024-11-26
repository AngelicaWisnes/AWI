
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

  OUT $(PE -txt:"Starting - Winget install --id $appID" -fg:$Global:colors.Cyan)
  if ($(Confirm-Action -Prompt "Installing $appID - Do you want to proceed?")) { 
    $ps5Process = Start-Process powershell -ArgumentList '-NoProfile', '-Command', $psScriptBlock -PassThru
    $ps5Process.WaitForExit()
  }

  if (Test-AppIsInstalled -appID $appID) {
    OUT $(PE -txt:"Finished - Installing $appID" -fg:$Global:colors.Green)
    Return $true
  }
  else { 
    OUT $(PE -txt:"Failed - Installing $appID" -fg:$Global:colors.Red) 
    Return $false
  }
}


function Test-AppIsInstalled {
  param([Parameter(Mandatory)][String]$appID)
  $private:app = winget list --id $appID 2>&1

  if ( $private:app -match 'No installed package found') {
    OUT $(PE -txt:'Is not installed: ' -fg:$Global:colors.Green), $(PE -txt:"$appID " -fg:$Global:colors.MintGreen)
    Return $false
  } 

  $flagName = Get-WingetFlagNameByAppID -appID $appID
  OUT $(PE -txt:'Is installed: ' -fg:$Global:colors.Green), $(PE -txt:"$appID " -fg:$Global:colors.MintGreen)
  Add-Flag -flagName $flagName
  Return $true
}


function Test-AppShouldBeInstalled {
  param([Parameter(Mandatory)][String]$appID)
  $flagName = Get-WingetFlagNameByAppID -appID $appID

  OUT $(PE -txt:'Checking - Should ' -fg:$Global:colors.Cyan), $(PE -txt:"$appID " -fg:$Global:colors.MintGreen), $(PE -txt:'be installed' -fg:$Global:colors.Cyan)
  
  if ($(Test-AppIsInstalled -appID $appID) -or $(Test-FlagExists -flagName $flagName)) { 
    OUT $(PE -txt:'Finished - Checking: ' -fg:$Global:colors.Green), $(PE -txt:"$appID " -fg:$Global:colors.MintGreen), $(PE -txt:"should NOT be installed`n" -fg:$Global:colors.Green)
    Return $false 
  }
  
  OUT $(PE -txt:'Finished - Checking: ' -fg:$Global:colors.Green), $(PE -txt:"$appID " -fg:$Global:colors.MintGreen), $(PE -txt:"should be installed`n" -fg:$Global:colors.Green)
  Return $true
}


function Test-AllAppsAreInstalled {
  foreach ($appID in $wingetAppIDs) {
    $flagName = Get-WingetFlagNameByAppID -appID $appID
    if (-not (Test-FlagExists -flagName $flagName)) { Return $false }
  }
  Return $true
}


function Get-WingetFlagNameByAppID {
  param([Parameter(Mandatory)][String]$appID)
  Return "winget-install-$($appID -replace '\.', '-')"  
}


function Install-Apps {
  OUT $(PE -txt:'Initiating - Winget app installation' -fg:$Global:colors.Cyan)
  
  foreach ($appID in $wingetAppIDs) {
    OUT $(PE -txt:'Starting - Procedure: ' -fg:$Global:colors.Cyan), $(PE -txt:"$appID" -fg:$Global:colors.MintGreen)
      
    $flagName = Get-WingetFlagNameByAppID -appID $appID
    if (-not $(Test-AppShouldBeInstalled -appID $appID)) { continue }
    $installed = Install-AppFromWinget -appID $appID
      
    if (-not $installed) { 
      OUT $(PE -txt:"Did not install $appID. " -fg:$Global:colors.Red), $(PE -txt:"Running this function again will by default attempt to install $appID again." -fg:$Global:colors.Cyan)
      if (-not $(Confirm-Action -Prompt 'Do you want to add a flag to prevent that?')) { continue }
    }
    else { OUT $(PE -txt:"Successfully installed $appID." -fg:$Global:colors.Green) }
      
    Add-Flag -flagName $flagName
    OUT $(PE -txt:'Finished - Procedure: ' -fg:$Global:colors.Green), $(PE -txt:"$appID" -fg:$Global:colors.MintGreen)
  }

  OUT $(PE -txt:'Finished - Winget app installer' -fg:$Global:colors.Green)
}


function Invoke-ExternalAppInstaller {
  $flagName = 'external-app-installer'
  if (Test-FlagExists -flagName $flagName) { Return }
  if (Confirm-Action -Prompt 'Do you want to run the external app installer?') { Install-Apps }
  
  OUT $(PE -txt:'Checking - Have all apps been installed' -fg:$Global:colors.Cyan)
  if (Test-AllAppsAreInstalled) { 
    OUT $(PE -txt:'All apps have been installed. Adding flag to prevent future running of external app installer' -fg:$Global:colors.Green)
    Add-Flag -flagName $flagName 
  }
  else {
    OUT $(PE -txt:'All apps have not been installed' -fg:$Global:colors.Red)
    if (Confirm-Action -Prompt 'Do you want to prevent running the external app installer again?') { Add-Flag -flagName $flagName }
  }
}
Add-ToFunctionList -category 'Setup' -name 'Invoke-ExternalAppInstaller' -value 'Selectively install apps using winget'
