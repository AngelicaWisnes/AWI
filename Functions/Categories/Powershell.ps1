
################################
# PowerShell-related functions #
################################
function Confirm-Action {
  param([Parameter(Mandatory)][String] $Prompt)

  Write-Host ('{0}{1} [Y/N] (Default - N): ' -f (cfg $Global:RGBs.White), $Prompt) -NoNewline
  $userInput = $Host.UI.RawUI.ReadKey().Character.ToString()
  If ($private:userInput.ToUpper() -eq 'Y') {
    Write-Info 'Proceeding with action...'
    Return $true
  }
  Else {
    Write-Info 'Proceeding without action...'
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
  Write-Info "`tReloading profile with start-path: `n`t$Global:startPath"
  . $global:AWI\AWI.ps1
}
Set-Alias ra ReloadAWI
Add-ToFunctionList -category 'PowerShell' -name '. ra' -value 'Reload AWI'


function ReloadPsProfile {
  $global:startPath = Get-Location
  Write-Info "`tReloading profile with start-path: `n`t$Global:startPath"
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
      If (-not $preSelection) { Write-Host ('{0}  {1,4} {2}- {3}' -f (cfg $Global:RGBs.Cyan), $Index.Value, $Prefix, $folder.Name) }
      Show-Tree -BasePath $folder.FullName -Index $Index -Prefix "$Prefix- " -RelativePath $currentRelativePath
    }
  }

  $index = [ref]0
  If (-not $preSelection) { Write-Info 'Directory-tree:' }
  Show-Tree -BasePath $Path -Index $index
  If (-not $preSelection) { Write-Info 'Enter the number of the folder you want to select: ' -NoNewline }

  $selection = If ($preSelection) { $preSelection } Else { Read-Host }
  If ($selection -le 0 -or $selection -gt $global:folderPaths.Count) { Write-Host 'Invalid selection. Please try again.' }

  Return $global:folderPaths[$selection - 1]
}
Add-ToFunctionList -category 'PowerShell' -name 'Get-SelectableFileTree' -value 'Get selectable file tree'

function Get-FunctionDefinition {
  param( [Parameter(Mandatory)][String]$commandName )
  $functionName = Get-FunctionNameFromCommandName( $commandName )
  If (-not $functionName) { Return }
  $codeBlock = Get-FunctionDefinitionAsString $functionName
  Write-Host ('{0}{1}' -f (cfg $Global:RGBs.White), $codeBlock)
}
Set-Alias see Get-FunctionDefinition
Add-ToFunctionList -category 'PowerShell' -name 'see' -value 'See the code-block of function'


function Get-FunctionNameFromCommandName {
  param( [Parameter(Mandatory)][String]$commandName )
  try {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue
    $commandType = $command.CommandType
  }
  catch {
    $commandType = 'NotFound'
  }
  If ( $commandType -eq 'Function' ) { Return $commandName }
  If ( $commandType -eq 'Alias' ) {
    Write-Info "`tCommand-name '$commandName' is an alias for Function-name '$($command.Definition)'"
    Return $command.Definition
  }
  Else { Write-Fail "Missing implementation for commandName '$commandName', in Get-FunctionNameFromCommandName" }
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
  Write-Host ("`n{0}{1} {2} {1} {3}" -f (cfg $Global:RGBs.White), $headerLine, $menuHeader, $rewritableLines)
  
  $initialCursorPosition = [System.Console]::CursorTop - $optionList.Length
  $initialCursorSize = $Host.UI.RawUI.CursorSize
  $Host.UI.RawUI.CursorSize = 0

  function printMenuWithCurrentSelectionHighlighted {
    [System.Console]::SetCursorPosition(0, $initialCursorPosition)
    for ($i = 0; $i -lt $optionList.Length; $i++) {
      $option = $optionList[$i]
      $label = If ($option.trigger) { "[$($option.trigger)] $($option.label)" } Else { $option.label }
      If ($i -eq $currentSelection) { Write-Host ('{0}>> {1}' -f (cfg $Global:RGBs.Cyan), $label) }
      Elseif ($i -eq ($optionList.Length - 1)) { Write-Host ('{0}   {1}' -f (cfg $Global:RGBs.Yellow), $label) }
      Else { Write-Host "   $label" }
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
  If ($currentSelection -eq $optionList.Length - 1) { Write-Host ("`n{0}Canceling..." -f (cfg $Global:RGBs.Red)) }
  Else { Write-Host ("`n{0}Executing..." -f (cfg $Global:RGBs.Cyan)) }
  
  $Host.UI.RawUI.CursorSize = $initialCursorSize
  $selectedOption.action.Invoke()
}
