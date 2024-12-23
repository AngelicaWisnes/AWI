
$AWI_profile = (Resolve-Path "$PSScriptRoot\..\AWI.ps1").Path
$AWI_import_statement = "`n# Import AWI package`n. (Resolve-Path `"$AWI_profile`")`n"
$psCommand = "Add-Content -Path `$PROFILE.CurrentUserCurrentHost -Value '$AWI_import_statement' -Encoding utf8"
$psScriptBlock = [scriptblock]::Create($psCommand)

function Confirm-Action {
  param( [Parameter(Mandatory)][String] $Prompt)

  $private:response = Read-Host "$Prompt - Do you want to proceed? [Y/N] (Default: Y)"
  If ($private:response.ToUpper() -eq 'Y' -or $private:response -eq '') {
    Write-Host -ForegroundColor Cyan 'Proceeding...'
    Return $true
  }
  Else {
    Write-Host -ForegroundColor Red 'Cancelled'
    Return $false
  }
}

function Add-AWIToPowershell5Profile {
  Write-Host -ForegroundColor Cyan 'Starting - Adding AWI to PowerShell 5 profile: '
  If ($(Confirm-Action -Prompt 'Adding to PowerShell 5')) {
    $ps5Process = Start-Process powershell -ArgumentList '-NoProfile', '-Command', $psScriptBlock -PassThru
    $ps5Process.WaitForExit()
  }
  Else { Return Write-Host -ForegroundColor Red 'Failed - Adding AWI to PowerShell 5 profile' }
  Write-Host -ForegroundColor Green 'Finished - Adding AWI to PowerShell 5 profile'
}

function Add-AWIToPowershell7Profile {
  Write-Host -ForegroundColor Cyan 'Starting - Adding AWI to PowerShell 7 profile: '
  If ($(Confirm-Action -Prompt 'Adding to PowerShell 7') -and $(Install-PowerShell7)) {
    $ps7Process = Start-Process pwsh -ArgumentList '-NoProfile', '-Command', $psScriptBlock -PassThru
    $ps7Process.WaitForExit()
  }
  Else { Return Write-Host -ForegroundColor Red 'Failed - Adding AWI to PowerShell 7 profile' }
  Write-Host -ForegroundColor Green 'Finished - Adding AWI to PowerShell 7 profile'
}

function Install-PowerShell7 {
  Write-Host -ForegroundColor Cyan 'Checking If PowerShell 7 is installed...'

  If (!(Get-Command 'pwsh' -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Red 'PowerShell 7 is not installed...'
    Write-Host -ForegroundColor Cyan 'Staring - Installing PowerShell 7...'

    If ($(Confirm-Action -Prompt 'Installing PowerShell 7')) { winget install --id Microsoft.PowerShell -e }

    If (!(Get-Command 'pwsh' -ErrorAction SilentlyContinue)) {
      Write-Host -ForegroundColor Red 'Failed PowerShell 7 installation'
      Return $false
    }
    Write-Host -ForegroundColor Green 'Successfully installed PowerShell 7'
  }

  Write-Host -ForegroundColor Green 'Finished - PowerShell 7 is installed'
  Return $true
}

function Confirm-Directory {
  Write-Host -ForegroundColor Cyan 'Checking directory...'
  $currentDir = (Resolve-Path "$PSScriptRoot\..\..").Path
  Write-Host -ForegroundColor Cyan "Current directory for installation is `n`t$currentDir"
  Return $(Confirm-Action -Prompt 'Installing AWI-package here')

}

function Install-AWI {
  Write-Host -ForegroundColor Cyan 'Starting - Installing the AWI-package to PowerShell...'

  If ($(Confirm-Directory)) {
    Add-AWIToPowershell5Profile
    Add-AWIToPowershell7Profile
    Write-Host -ForegroundColor Green 'Finished - The AWI-package is installed in PowerShell'
  }
  Else {
    Write-Host -ForegroundColor Red 'Installation cancelled. Place the AWI-package in the desired directory, and start again'
    Start-Sleep -Seconds 3
  }
  Write-Host -ForegroundColor Cyan 'Ending the PowerShell session...'
  Start-Sleep -Seconds 3
}

Install-AWI
