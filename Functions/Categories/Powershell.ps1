
################################
# PowerShell-related functions #
################################
function Set-LocationOneBack { Set-Location .. }
Set-Alias cd. Set-LocationOneBack
Add-ToFunctionList -category "PowerShell" -name 'cd.' -value 'cd ..'


function Edit-AWIProfile { code $global:AWI }
Set-Alias ep Edit-AWIProfile
Add-ToFunctionList -category "PowerShell" -name 'ep' -value 'Edit AWI'


function Edit-AWIAndPsProfile { 
  Edit-AWIProfile
  code $profile 
}
Set-Alias epp Edit-AWIAndPsProfile
Add-ToFunctionList -category "PowerShell" -name 'epp' -value 'Edit AWI and PS-profile'

function Get-FullPath { (Resolve-Path .\).Path }
Set-Alias pa Get-FullPath
Add-ToFunctionList -category "PowerShell" -name 'pa' -value 'Get current path'


function Get-CurrentRepo { Split-Path -Leaf (Get-FullPath) }
Set-Alias re Get-CurrentRepo
Add-ToFunctionList -category "PowerShell" -name 're' -value 'Get current repo'


function Push-LocationHome { Push-Location $global:DEFAULT_START_PATH }
Set-Alias home Push-LocationHome
Add-ToFunctionList -category "PowerShell" -name 'home' -value 'Push-Location default-start-path'

Set-Alias i Invoke-History
Add-ToFunctionList -category "PowerShell" -name 'i' -value 'Invoke-History'

function Reset-Color { [console]::ResetColor() }
Set-Alias rc Reset-Color
Add-ToFunctionList -category "PowerShell" -name 'rc' -value 'Reset color scheme'

function Push-LocationAWI { Push-Location $global:AWI }
Set-Alias awi Push-LocationAWI
Add-ToFunctionList -category "PowerShell" -name 'awi' -value 'Push-Location $AWI'


function ReloadAWI { 
  $startPath = Get-Location
  OUT $(PE -txt:"`tReloading profile with startpath: `n`t$startpath`n" -fg:$global:colors.Cyan)
  . $global:AWI\AWI.ps1
}
Set-Alias ra ReloadAWI
Add-ToFunctionList -category "PowerShell" -name '. ra' -value 'Reload AWI'


function ReloadPsProfile { 
  $startPath = Get-Location
  OUT $(PE -txt:"`tReloading profile with startpath: `n`t$startpath`n" -fg:$global:colors.Cyan)
  . $profile
}
Set-Alias rap ReloadPsProfile
Add-ToFunctionList -category "PowerShell" -name '. rap' -value 'Reload PS-profile'


function Get-FunctionDefinition {
  param( [Parameter(Mandatory)][String]$commandName )
  $functionName = Get-FunctionNameFromCommandName( $commandName )
  $codeBlock = Get-FunctionDefinitionAsString $functionName
  OUT $(PE -txt:$codeBlock -fg:$global:colors.White)
}
Set-Alias see Get-FunctionDefinition
Add-ToFunctionList -category "PowerShell" -name 'see' -value 'See the code-block of function'


function Get-FunctionNameFromCommandName {
  param( [Parameter(Mandatory)][String]$commandName )
  $command = Get-Command $commandName
  $commandType = $command.CommandType
  If ( $commandType -eq "Function" ) { Return $commandName }
  If ( $commandType -eq "Alias" ) { 
    OUT $(PE -txt:"`tCommand-name '$commandName' is an alias for Function-name '$($command.Definition)'`n" -fg:$global:colors.Cyan)
    Return $command.Definition 
  }
  Else { OUT $(PE -txt:"`tMISSING IMPLEMENTATION FOR COMMAND-TYPE '$commandType', in Get-FunctionNameFromCommandName`n" -fg:$global:colors.Red) }
}

function Get-WindowDimensions {
  param(
  [int]$heightPadding = 13,
  [int]$widthPadding = 1
  )
  $windowWidth = $Host.UI.RawUI.WindowSize.Width - $widthPadding
  $windowHeight = $Host.UI.RawUI.WindowSize.Height - $heightPadding
  Return @($windowWidth, $windowHeight)
}

function Get-FunctionDefinitionAsString { Return (Get-Command $args).ScriptBlock }


function Start-NewPowershell {
  param (
    [scriptblock]$script = { param($currentPath); Set-Location $currentPath; },
    [array]$params = ($(Get-FullPath))
  )

  Start-Process $global:MY_POWERSHELL -ArgumentList `
    "-NoExit -Command & { $($script -replace '"', '\"') } $params"
}
Set-Alias snp Start-NewPowershell
Add-ToFunctionList -category "PowerShell" -name 'snp' -value 'Start new powershell'




$subDirUtils = @{
  current     = 0 ; 
  root        = Get-FullPath;
  directories = (Get-ChildItem -Directory).name;
  dirCount    = 0;
  initialized = $false
}

# TODO: Check if this function is completed - If not: Complete it
function _openAllSubDirs_continue {
  If ( $subDirUtils.dirCount -eq 0 ) { Return OUT $(PE -txt:"No subdirectories found" -fg:$global:colors.Red) }
  If ( $subDirUtils.current -eq $subDirUtils.dirCount ) { Return OUT $(PE -txt:"Finished" -fg:$global:colors.Red) }

  $currentDir = $subDirUtils.directories[$subDirUtils.current]
  Write-Host -ForegroundColor Cyan "Current directory: $($subDirUtils.current+1)/$($subDirUtils.dirCount) `n  $currentDir `n"
  Set-Location ("$($subDirUtils.root)\$currentDir" | Resolve-Path)
  $subDirUtils.current += 1
}

# TODO: Check if this function is completed - If not: Complete it
function _openAllSubDirs_init {
  $subDirUtils.current = 0
  $subDirUtils.root = Get-FullPath
  $subDirUtils.directories = (Get-ChildItem -Directory).name
  $subDirUtils.dirCount = $($subDirUtils.directories).Count
  $subDirUtils.initialized = $True
  
  Write-Host -ForegroundColor Cyan "
    Started 'openAllSubDirs -Init'. This will Set-Location for every subdirectory in current directory ($($subDirUtils.dirCount) times). 
    NOTE: This function does not handle recursion, and will reset if run again with 'init'-parameter!

    Run 'openAllSubDirs' to precede to the next subdirectory.`n"
}

# TODO: Check if this function is completed - If not: Complete it
function openAllSubDirs {
  param( [switch]$Init = $False )
  If ( $Init -or (-not $subDirUtils.initialized) ) { _openAllSubDirs_init }
  Else { _openAllSubDirs_continue }
}
