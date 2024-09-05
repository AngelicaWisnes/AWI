
$AWI_profile = (Resolve-Path "$PSScriptRoot\..\AWI.ps1").Path
$AWI_import_statement = "`n# Import AWI package`n. (Resolve-Path `"$AWI_profile`")`n"
$psCommand = "Add-Content -Path `$PROFILE.CurrentUserCurrentHost -Value '$AWI_import_statement' -Encoding utf8"
$psScriptBlock = [scriptblock]::Create($psCommand)

function Confirm-Action {
    param( [Parameter(Mandatory)][String] $Prompt)

    $private:response = Read-Host "$Prompt - Do you want to proceed? [Y/N] (Default: Y)"
    if ($private:response -eq 'Y' -or $private:response -eq 'y' -or $private:response -eq '') {
        Write-Host -ForegroundColor Cyan "Proceeding..."
        return $true
    }
    else {
        Write-Host -ForegroundColor Red "Cancelled"
        return $false
    }
}

function Add-AWIToPowershell5Profile {
    Write-Host -ForegroundColor Cyan "Starting - Adding AWI to PowerShell 5 profile: "
    if ($(Confirm-Action -Prompt "Adding to PowerShell 5")) { 
        $ps5Process = Start-Process powershell -ArgumentList "-NoProfile", "-Command", $psScriptBlock -PassThru
        $ps5Process.WaitForExit()
    }
    else { return Write-Host -ForegroundColor Red "Failed - Adding AWI to PowerShell 5 profile" }
    Write-Host -ForegroundColor Green "Finished - Adding AWI to PowerShell 5 profile"
}

function Add-AWIToPowershell7Profile {
    Write-Host -ForegroundColor Cyan "Starting - Adding AWI to PowerShell 7 profile: "
    if ($(Confirm-Action -Prompt "Adding to PowerShell 7") -and $(Install-PowerShell7)) { 
        $ps7Process = Start-Process pwsh -ArgumentList "-NoProfile", "-Command", $psScriptBlock -PassThru
        $ps7Process.WaitForExit()
    }
    else { return Write-Host -ForegroundColor Red "Failed - Adding AWI to PowerShell 7 profile" }
    Write-Host -ForegroundColor Green "Finished - Adding AWI to PowerShell 7 profile"
}

function Install-PowerShell7 {
    Write-Host -ForegroundColor Cyan "Checking if PowerShell 7 is installed..."
    
    if (!(Get-Command "pwsh" -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Red "PowerShell 7 is not installed..."
        Write-Host -ForegroundColor Cyan "Staring - Installing PowerShell 7..."  

        if ($(Confirm-Action -Prompt "Installing PowerShell 7")) { winget install --id Microsoft.PowerShell -e }   
        
        if (!(Get-Command "pwsh" -ErrorAction SilentlyContinue)) { 
            Write-Host -ForegroundColor Red "Failed PowerShell 7 installation" 
            return $false
        }
        Write-Host -ForegroundColor Green "Successfully installed PowerShell 7" 
    }
    
    Write-Host -ForegroundColor Green "Finished - PowerShell 7 is installed"
    return $true
}

function Confirm-Directory {
    Write-Host -ForegroundColor Cyan "Checking directory..."
    $currentDir = (Resolve-Path "$PSScriptRoot\..\..").Path
    Write-Host -ForegroundColor Cyan "Current directory for installation is `n`t$currentDir"
    return $(Confirm-Action -Prompt "Installing AWI-package here")
    
}

function Install-AWI {
    Write-Host -ForegroundColor Cyan "Starting - Installing the AWI-package to PowerShell..."
    
    if ($(Confirm-Directory)) {
        Add-AWIToPowershell5Profile
        Add-AWIToPowershell7Profile
        Write-Host -ForegroundColor Green "Finished - The AWI-package is installed in PowerShell"
    }
    else {
        Write-Host -ForegroundColor Red "Installation cancelled. Place the AWI-package in the desired directory, and start again" 
        Start-Sleep -Seconds 3
    }
    Write-Host -ForegroundColor Cyan "Ending the PowerShell session..."
    Start-Sleep -Seconds 3
}

Install-AWI




