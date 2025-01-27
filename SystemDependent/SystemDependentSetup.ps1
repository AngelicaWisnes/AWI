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
    Return Write-Info ('Cancelled setting {0}{1}' -f (cfg $Global:RGBs.MintGreen), $variableString)
  }
  Write-Info 'Proceeding...'

  # Read content from file
  $file = $global:SYSTEM_CONSTANTS_PATH
  If (!(Test-Path $file)) { Return Write-Fail ('File not found: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $file) }
  $content = Get-Content $file

  # Find matching line in the file
  $matchedLine = $content | Select-String -SimpleMatch $variableString | Select-Object -First 1
  If (!$matchedLine) {
    Return Write-Fail ('The string {0}{1}{3} was not found in the file {0}{2}' -f (cfg $Global:RGBs.MintGreen), $variableString, $file, (cfg $Global:RGBs.Red)) 
  }

  # Extract line number and content
  $lineNumber = $matchedLine.LineNumber
  $lineContent = $matchedLine.Line
  Write-Info ("Current value:`n  Line {0}{1} - {2}`n" -f (cfg $Global:RGBs.MintGreen), $lineNumber, $lineContent)

  # Prompt user for new path
  $pathString = Read-Host 'Enter full path to the file'
  If (![string]::IsNullOrWhiteSpace($pathString)) {
    $formattedPath = Format-VariablePath $pathString

    If (-not $formattedPath) { Return Write-Fail 'Failed setting variable' }

    # Update line content with new path
    $newLineContent = $variableString + $formattedPath
    Write-Info ("New value:`n  Line {0}{1} - {2}`n" -f (cfg $Global:RGBs.MintGreen), $lineNumber, $lineContent)
    $content[$lineNumber - 1] = $newLineContent

    # Write updated content back to file
    Set-Content -Path $file -Value $content
    Write-Success ("File {0}{1}{2} has been modified.`n" -f (cfg $Global:RGBs.MintGreen), $file, (cfg $Global:RGBs.MintGreen))
  }
}

function Format-VariablePath {
  param( [Parameter(Mandatory)][string]$pathString )
  $pathString = $pathString.Replace("`"", '')

  If (-not (Test-Path -Path $pathString)) {
    Write-Fail ('The specified path {0}{1}{2} is invalid or does not exist.' -f (cfg $Global:RGBs.MintGreen), $pathString, (cfg $Global:RGBs.Red))
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
function Get-SystemDependentBranchPrefixes { SystemDependentBranchPrefixes }


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
# TODO: Add flags instead of hardcoding the muted value
function Test-PathVariables {
  $writeWarning = $false

  Foreach ($path in $SystemDependentPaths) {
    If ( (('' -eq $path.variable) -or (-not (Test-Path $path.variable))) -and (-not $path.muted) ) {
      Write-Fail ("Missing or broken path: `n{0}{1} {2}" -f (cfg $Global:RGBs.MintGreen), $path.name, $path.value)
      $writeWarning = $true
    }
  }

  If ($writeWarning) {
    Write-Host ("{0}`n  When these variables are not set, some functions may not work as intended. This prompt will keep appearing on PowerShell session startup unless the variables are set or muted" -f (cfg $Global:RGBs.Red))
    Write-Host ("{0}  To mute the prompt, set the value of `$muted to true, in `$SystemDependentPaths, in $PSScriptRoot/SystemDependentSetup.ps1`n" -f (cfg $Global:RGBs.Red))

    $private:response = Read-Host '- Do you want to set the variables? [Y/N] (Default: Y)'
    If ($private:response -eq 'Y' -or $private:response -eq 'y' -or $private:response -eq '') {
      Write-Info 'Proceeding...'
      Foreach ($path in $SystemDependentPaths) {
        If ( (('' -eq $path.variable) -or (-not (Test-Path $path.variable))) -and (-not $path.muted) ) {
          Write-Fail ("Missing or broken path: `n{0}{1} {2}" -f (cfg $Global:RGBs.MintGreen), $path.name, $path.value)
          If (-not $path.muted) { Set-PathVariable $path.name }
        }
      }
    }
  }
}

Test-PathVariables
