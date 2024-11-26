# Suppress 'unused-variable'-warning for this file
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()


# Define system-dependent paths
$global:SYSTEM_OS = [System.Environment]::OSVersion.VersionString
$global:SYSTEM_NAME = WhoAmI #Alternative to WhoAmI:   [System.Security.Principal.WindowsIdentity]::GetCurrent().name
$sysDepRoot = Join-Path $PSScriptRoot $global:SYSTEM_NAME
$global:SYSTEM_CONSTANTS_PATH = Join-Path $sysDepRoot SystemDependentConstants.ps1
$global:SYSTEM_PROJECTS_PATH = Join-Path $sysDepRoot SystemDependentProjects.ps1
$global:SYSTEM_FUNCTIONS_PATH = Join-Path $sysDepRoot SystemDependentFunctions.ps1


function Copy-TemplateDirectory {
  $systemDirectory = Join-Path $PSScriptRoot $global:SYSTEM_NAME
  If (-not (Test-Path $systemDirectory)) {
    New-Item -ItemType Directory -Path $systemDirectory > $null
  }
  $templateDirectory = Join-Path $PSScriptRoot 'Template'
  If (Test-Path $templateDirectory) {
    Copy-Item -Path "$templateDirectory\*" -Destination $systemDirectory -Recurse > $null
  }
}

function Set-PathVariable {
  param( [Parameter(Mandatory)][String]$variableString )

  # Prompt user for confirmation
  $response = Read-Host "- Do you want to set '$variableString'? [Y/N] (Default: Y)"
  If (![string]::IsNullOrWhiteSpace($response) -and $response.ToLower() -ne 'y') {
    Return Write-Host -ForegroundColor Red "Cancelled setting $variableString"
  }
  Write-Host -ForegroundColor Cyan 'Proceeding...'

  # Read content from file
  $file = $global:SYSTEM_CONSTANTS_PATH
  If (!(Test-Path $file)) { Return Write-Host -ForegroundColor Red "File not found: $file" }
  $content = Get-Content $file

  # Find matching line in the file
  $matchedLine = $content | Select-String -SimpleMatch $variableString | Select-Object -First 1
  If (!$matchedLine) { Return Write-Host -ForegroundColor Red "The string '$variableString' was not found in the file '$file'" }

  # Extract line number and content
  $lineNumber = $matchedLine.LineNumber
  $lineContent = $matchedLine.Line
  Write-Host "Current value:`n  Line $lineNumber - $lineContent`n"

  # Prompt user for new path
  $pathString = Read-Host 'Enter full path to the file'
  If (![string]::IsNullOrWhiteSpace($pathString)) {
    $formattedPath = Format-VariablePath $pathString

    If (-not $formattedPath) { Return Write-Host -ForegroundColor Red 'Failed setting variable' }

    # Update line content with new path
    $newLineContent = $variableString + $formattedPath
    Write-Host "New value:`n  Line $lineNumber - $newLineContent`n"
    $content[$lineNumber - 1] = $newLineContent

    # Write updated content back to file
    Set-Content -Path $file -Value $content
    Write-Host -ForegroundColor Green "File '$file' has been modified.`n"
  }
}

function Format-VariablePath {
  param( [Parameter(Mandatory)][string]$pathString )
  $pathString = $pathString.Replace("`"", '')

  If (-not (Test-Path -Path $pathString)) {
    Write-Host -ForegroundColor Red "The specified path '$pathString' is invalid or does not exist."
    Return $null
  }

  If (Test-Path -Path $pathString -PathType Container) {
    Return "Resolve-Path `"$pathString`""
  }

  $directory = Split-Path -Path $pathString -Parent
  $directory = $directory.Replace('/', '\')
  $fileName = Split-Path -Path $pathString -Leaf

  Return "Join-Path `"$directory`" `"$fileName`""
}



########################################
###      SETUP SYSTEM DEPENDENCY     ###
########################################

# Import SystemDependent Constants
If (-not (Test-Path $sysDepRoot)) { Copy-TemplateDirectory }
. (Resolve-Path $global:SYSTEM_CONSTANTS_PATH)
. (Resolve-Path $global:SYSTEM_PROJECTS_PATH)
. (Resolve-Path $global:SYSTEM_FUNCTIONS_PATH)


# Specify SystemDependentFunction-getters for general usage
function Get-SystemDependentGitCheckouts { SystemDependentGitCheckouts }


# Specify all relevant SystemDependentPaths:
class SDP { [string]$variable ; [string]$name ; [string]$value ; [bool]$muted }
$SystemDependentPaths = @(
  [SDP]@{variable = $global:SYSTEM_CONSTANTS_PATH    ; name = "`$global:SYSTEM_CONSTANTS_PATH = "   ; value = "$global:SYSTEM_CONSTANTS_PATH" ; muted = $false }
  [SDP]@{variable = $global:SYSTEM_PROJECTS_PATH     ; name = "`$global:SYSTEM_PROJECTS_PATH = "    ; value = "$global:SYSTEM_PROJECTS_PATH"  ; muted = $false }
  [SDP]@{variable = $global:SYSTEM_FUNCTIONS_PATH    ; name = "`$global:SYSTEM_FUNCTIONS_PATH = "   ; value = "$global:SYSTEM_FUNCTIONS_PATH" ; muted = $false }

  [SDP]@{variable = $global:MY_POWERSHELL_5          ; name = "`$global:MY_POWERSHELL_5 = "         ; value = "$global:MY_POWERSHELL_5"       ; muted = $false }
  [SDP]@{variable = $global:MY_POWERSHELL_7          ; name = "`$global:MY_POWERSHELL_7 = "         ; value = "$global:MY_POWERSHELL_7"       ; muted = $false }
  [SDP]@{variable = $global:MY_POWERSHELL            ; name = "`$global:MY_POWERSHELL = "           ; value = "$global:MY_POWERSHELL"         ; muted = $true }
  [SDP]@{variable = $global:MY_BROWSER               ; name = "`$global:MY_BROWSER = "              ; value = "$global:MY_BROWSER"            ; muted = $false }
  [SDP]@{variable = $global:MY_DOTNET_IDE            ; name = "`$global:MY_DOTNET_IDE = "           ; value = "$global:MY_DOTNET_IDE"         ; muted = $false }
  [SDP]@{variable = $global:MY_JS_IDE                ; name = "`$global:MY_JS_IDE = "               ; value = "$global:MY_JS_IDE"             ; muted = $false }
  [SDP]@{variable = $global:DEFAULT_START_PATH       ; name = "`$global:DEFAULT_START_PATH = "      ; value = "$global:DEFAULT_START_PATH"    ; muted = $false }
)

# Check paths' validity
function Test-PathVariables {
  $writeWarning = $false

  Foreach ($path in $SystemDependentPaths) {
    If ( (('' -eq $path.variable) -or (-not (Test-Path $path.variable))) -and (-not $path.muted) ) {
      Write-Host -ForegroundColor red "Missing or broken path: `n`"$($path.name) $($path.value)`"`n"
      $writeWarning = $true
    }
  }

  If ($writeWarning) {
    Write-Host -ForegroundColor Red "`n  When these variables are not set, some functions may not work as intended. This prompt will keep appearing on PowerShell session startup unless the variables are set or muted"
    Write-Host -ForegroundColor Red "  To mute the prompt, set the value of `$muted to true, in `$SystemDependentPaths, in $PSScriptRoot/SystemDependentSetup.ps1`n"

    $private:response = Read-Host '- Do you want to set the variables? [Y/N] (Default: Y)'
    If ($private:response -eq 'Y' -or $private:response -eq 'y' -or $private:response -eq '') {
      Write-Host -ForegroundColor Cyan 'Proceeding...'
      Foreach ($path in $SystemDependentPaths) {
        If ( (('' -eq $path.variable) -or (-not (Test-Path $path.variable))) -and (-not $path.muted) ) {
          Write-Host -ForegroundColor red "Missing or broken path: `n`"$($path.name) $($path.value)`"`n"
          If (-not $path.muted) { Set-PathVariable $path.name }
        }
      }
    }
  }
}

Test-PathVariables
