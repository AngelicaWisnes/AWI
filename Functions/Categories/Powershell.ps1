
################################
# PowerShell-related functions #
################################
function Confirm-Action {
  param([Parameter(Mandatory)][String] $Prompt)

  OUT $(PE -txt:"$Prompt [Y/N] (Default - N): " -fg:$global:colors.White) -NoNewline
  $userInput = $Host.UI.RawUI.ReadKey().Character.ToString()
  If ($private:userInput.ToUpper() -eq 'Y') {
    OUT $(PE -txt:"`nProceeding with action..." -fg:$Global:colors.Cyan)
    Return $true
  }
  Else {
    OUT $(PE -txt:"`nProceeding without action..." -fg:$Global:colors.Cyan)
    Return $false
  }
}


function Set-LocationOneBack { Set-Location .. }
Set-Alias cd. Set-LocationOneBack
Add-ToFunctionList -category 'PowerShell' -name 'cd.' -value 'cd ..'


function Edit-AWIProfile { code $global:AWI }
Set-Alias ep Edit-AWIProfile
Add-ToFunctionList -category 'PowerShell' -name 'ep' -value 'Edit AWI'


function Edit-AWIAndPsProfile {
  Edit-AWIProfile
  code $profile
}
Set-Alias epp Edit-AWIAndPsProfile
Add-ToFunctionList -category 'PowerShell' -name 'epp' -value 'Edit AWI and PS-profile'

function Get-FullPath { (Resolve-Path .\).Path }
Set-Alias pa Get-FullPath
Add-ToFunctionList -category 'PowerShell' -name 'pa' -value 'Get current path'


function Get-CurrentRepo { Split-Path -Leaf (Get-FullPath) }
Set-Alias re Get-CurrentRepo
Add-ToFunctionList -category 'PowerShell' -name 're' -value 'Get current repo'


function Push-LocationHome { Push-Location $global:DEFAULT_START_PATH }
Set-Alias home Push-LocationHome
Add-ToFunctionList -category 'PowerShell' -name 'home' -value 'Push-Location default-start-path'

Set-Alias i Invoke-History
Add-ToFunctionList -category 'PowerShell' -name 'i' -value 'Invoke-History'

function Reset-Color { [console]::ResetColor() }
Set-Alias rc Reset-Color
Add-ToFunctionList -category 'PowerShell' -name 'rc' -value 'Reset color scheme'

function Push-LocationAWI { Push-Location $global:AWI }
Set-Alias awi Push-LocationAWI
Add-ToFunctionList -category 'PowerShell' -name 'awi' -value 'Push-Location $AWI'


function ReloadAWI {
  $global:startPath = Get-Location
  OUT $(PE -txt:"`tReloading profile with start-path: `n`t$global:startPath`n" -fg:$global:colors.Cyan)
  . $global:AWI\AWI.ps1
}
Set-Alias ra ReloadAWI
Add-ToFunctionList -category 'PowerShell' -name '. ra' -value 'Reload AWI'


function ReloadPsProfile {
  $global:startPath = Get-Location
  OUT $(PE -txt:"`tReloading profile with start-path: `n`t$global:startPath`n" -fg:$global:colors.Cyan)
  . $profile
}
Set-Alias rap ReloadPsProfile
Add-ToFunctionList -category 'PowerShell' -name '. rap' -value 'Reload PS-profile'

function Get-SelectableFileTree {
  param([string]$preSelection)

  $Path = (Join-Path -Path (Get-Location) -ChildPath 'src')
  $global:folderPaths = @()

  function Show-Tree {
    param (
      [string]$BasePath,
      [ref]$Index,
      [string]$Prefix = '',
      [string]$RelativePath = ''
    )

    $folders = Get-ChildItem -Path $BasePath -Directory | Where-Object { $_.Name -ne 'node_modules' }

    foreach ($folder in $folders) {
      $Index.Value++
      $currentRelativePath = If ($RelativePath) { Join-Path -Path $RelativePath -ChildPath $folder.Name } Else { $folder.Name }
      $global:folderPaths += $currentRelativePath
      If (-not $preSelection) { OUT $(PE -txt:$('  {0,4} {1}- {2}' -f $Index.Value, $Prefix, $folder.Name) -fg:$global:colors.Cyan) -NoNewlineStart }
      Show-Tree -BasePath $folder.FullName -Index $Index -Prefix "$Prefix- " -RelativePath $currentRelativePath
    }
  }

  $index = [ref]0
  If (-not $preSelection) { OUT $(PE -txt:'Directory-tree:' -fg:$global:colors.Cyan) }
  Show-Tree -BasePath $Path -Index $index
  If (-not $preSelection) { OUT $(PE -txt:'Enter the number of the folder you want to select: ' -fg:$global:colors.Cyan) -NoNewline }

  $selection = If ($preSelection) { $preSelection } Else { Read-Host }
  If ($selection -le 0 -or $selection -gt $global:folderPaths.Count) { Write-Host 'Invalid selection. Please try again.' }

  Return $global:folderPaths[$selection - 1]
}
Add-ToFunctionList -category 'PowerShell' -name 'Get-SelectableFileTree' -value 'Get selectable file tree'

function Get-FunctionDefinition {
  param( [Parameter(Mandatory)][String]$commandName )
  $functionName = Get-FunctionNameFromCommandName( $commandName )
  $codeBlock = Get-FunctionDefinitionAsString $functionName
  OUT $(PE -txt:$codeBlock -fg:$global:colors.White)
}
Set-Alias see Get-FunctionDefinition
Add-ToFunctionList -category 'PowerShell' -name 'see' -value 'See the code-block of function'


function Get-FunctionNameFromCommandName {
  param( [Parameter(Mandatory)][String]$commandName )
  $command = Get-Command $commandName
  $commandType = $command.CommandType
  If ( $commandType -eq 'Function' ) { Return $commandName }
  If ( $commandType -eq 'Alias' ) {
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
Add-ToFunctionList -category 'PowerShell' -name 'snp' -value 'Start new powershell'


function Show-NavigableMenu {
  param ( 
    [Parameter(mandatory)][array]$options,
    [string]$menuHeader = 'Menu'
  )
  $optionList = @()
  foreach ($option in $options) { $optionList += $option }
  $optionList += [NavigableMenuElement]@{label = '[Any] Cancel'; action = { return } }

  $rewritableLines = "`n" * $optionList.Length
  $lineWidth = (($optionList.label) | Measure-Object -Maximum -Property:Length).Maximum
  $headerLine = '=' * ($lineWidth / 2)
  OUT $(PE -txt:"$headerLine $menuHeader $headerLine $rewritableLines" -fg:$global:colors.White)
  
  $initialCursorPosition = [System.Console]::CursorTop - $optionList.Length
  $initialCursorSize = $Host.UI.RawUI.CursorSize
  $Host.UI.RawUI.CursorSize = 0

  function printMenuWithCurrentSelectionHighlighted {
    [System.Console]::SetCursorPosition(0, $initialCursorPosition)
    for ($i = 0; $i -lt $optionList.Length; $i++) {
      $option = $optionList[$i]
      $label = If ($option.trigger) { "[$($option.trigger)] $($option.label)" } Else { $option.label }
      If ($i -eq $currentSelection) { OUT $(PE -txt:">> $label" -fg:$global:colors.Cyan) -NoNewlineStart }
      Elseif ($i -eq ($optionList.Length - 1)) { OUT $(PE -txt:"   $label" -fg:$global:colors.Yellow) -NoNewlineStart }
      Else { OUT $(PE -txt:"   $label") -NoNewlineStart }
    }
  }
  
  $currentSelection = 0
  :outerLoop while ($true) {
    printMenuWithCurrentSelectionHighlighted
    
    # Read user input
    $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

    # Handle trigger key selection
    for ($i = 0; $i -lt $optionList.Length; $i++) {
      If ($optionList[$i].trigger -and ($optionList[$i].trigger -eq $key.Character.ToString().ToUpper())) { 
        $currentSelection = $i
        break outerLoop
      }
    }
    
    # Handle arrow key navigation
    switch ($key.VirtualKeyCode) {
      13 { break outerLoop }                                                          # Enter key
      38 { If ($currentSelection -gt 0) { $currentSelection-- } }                     # Up arrow
      40 { If ($currentSelection -lt ($optionList.Length - 1)) { $currentSelection++ } } # Down arrow
      default {
        $currentSelection = $optionList.Length - 1 
        break outerLoop 
      }                                                                               # Any other key
    }
  }
  printMenuWithCurrentSelectionHighlighted

  $selectedOption = $optionList[$currentSelection] 
  If ($currentSelection -eq $optionList.Length - 1) { OUT $(PE -txt:'Canceling...' -fg:$global:colors.Red) }
  Else { OUT $(PE -txt:"Executing...`n" -fg:$global:colors.Cyan) }
  
  $Host.UI.RawUI.CursorSize = $initialCursorSize
  $selectedOption.action.Invoke()
}


$subDirUtils = @{
  current     = 0
  root        = Get-FullPath
  directories = (Get-ChildItem -Directory).name
  dirCount    = 0
  initialized = $false
}

# TODO: Check If this function is completed - If not: Complete it
function _openAllSubDirs_continue {
  If ( $subDirUtils.dirCount -eq 0 ) { Return OUT $(PE -txt:'No subdirectories found' -fg:$global:colors.Red) }
  If ( $subDirUtils.current -eq $subDirUtils.dirCount ) { Return OUT $(PE -txt:'Finished' -fg:$global:colors.Red) }

  $currentDir = $subDirUtils.directories[$subDirUtils.current]
  Write-Host -ForegroundColor Cyan "Current directory: $($subDirUtils.current+1)/$($subDirUtils.dirCount) `n  $currentDir `n"
  Set-Location ("$($subDirUtils.root)\$currentDir" | Resolve-Path)
  $subDirUtils.current += 1
}

# TODO: Check If this function is completed - If not: Complete it
function _openAllSubDirs_init {
  $subDirUtils.current = 0
  $subDirUtils.root = Get-FullPath
  $subDirUtils.directories = (Get-ChildItem -Directory).name
  $subDirUtils.dirCount = $($subDirUtils.directories).Count
  $subDirUtils.initialized = $True

  Write-Host -ForegroundColor Cyan "
    Started 'openAllSubDirs -Init'. This will Set-Location for every subdirectory in current directory ($($subDirUtils.dirCount) times).
    NOTE: This function does not handle recursion, and will reset If run again with 'init'-parameter!

    Run 'openAllSubDirs' to precede to the next subdirectory.`n"
}

# TODO: Check If this function is completed - If not: Complete it
function openAllSubDirs {
  param( [switch]$Init = $False )
  If ( $Init -or (-not $subDirUtils.initialized) ) { _openAllSubDirs_init }
  Else { _openAllSubDirs_continue }
}
