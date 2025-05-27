
################################
# PowerShell-related functions #
################################
function Confirm-Action {
  param([Parameter(Mandatory)][String] $Prompt)

  Write-Host ('{0}{1} [Y/N] (Default - N): ' -f $Global:RGBs.White.fg, $Prompt) -NoNewline
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
      If (-not $preSelection) { Write-Host ('{0}  {1,4} {2}- {3}' -f $Global:RGBs.Cyan.fg, $Index.Value, $Prefix, $folder.Name) }
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
  Write-Host ('{0}{1}' -f $Global:RGBs.White.fg, $codeBlock)
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
  $windowWidth, $windowHeight = Get-WindowDimensions  
  $menuHeight = @($windowHeight, 15, $options.Length | Measure-Object -Minimum).Minimum
  $isOnlyOneList = $menuHeight -ge $options.Length
  
  $maxDigits = ($options.Length - 1).ToString().Length

  $upArrow = [char]0x2191    # ↑
  $downArrow = [char]0x2193  # ↓
  $leftArrow = If ($isOnlyOneList) { '' } Else { [char]0x2190 }  # ←
  $rightArrow = If ($isOnlyOneList) { '' } Else { [char]0x2192 } # →

  $lineWidth = (($options.label) | Measure-Object -Maximum -Property:Length).Maximum
  $headerLine = '=' * [Math]::Ceiling( ($lineWidth - $menuHeader.Length + 6) / 2 )
  $navigationInfo = ('{0}{1}{2}{3}' -f $leftArrow, $upArrow, $downArrow, $rightArrow)
  Write-Host $("`n" * ($menuHeight + 2))

  $initialCursorPosition = [System.Console]::CursorTop - $menuHeight - 3
  $initialCursorSize = $Host.UI.RawUI.CursorSize
  $Host.UI.RawUI.CursorSize = 0
  
  $listStartIndex = 0
  :ListSelectionLoop while ($true) {
    $listStopIndex = [Math]::Min($listStartIndex + $menuHeight - 1, $options.Length - 1)
    
    $currentList = @()
    foreach ($option in $options[$listStartIndex..$listStopIndex]) { $currentList += $option }
    $currentList += [NavigableMenuElement]@{label = '[Any] Cancel'; action = { return } }
    $currentListLength = $currentList.Length - 1
    
    $currentSelection = 0
    function printMenuWithCurrentSelectionHighlighted {
      [System.Console]::SetCursorPosition(0, $initialCursorPosition)
     
      $indexInfo = ("({0,$maxDigits} - {1,$maxDigits} / {2,$maxDigits} | {3})" -f $listStartIndex, $listStopIndex, ($options.Length - 1), $navigationInfo)
      Write-Host ("`n{0}{1} {2} {3} {1}" -f $Global:RGBs.White.fg, $headerLine, $menuHeader, $indexInfo)
     
      for ($i = 0; $i -le $currentListLength; $i++) {
        $option = $currentList[$i]
        $label = If ($option.trigger) { "[$($option.trigger)] $($option.label)" } Else { $option.label }
        $trailingSpaces = ' ' * ($windowWidth - $label.Length - 3)

        If ($i -eq $currentSelection) { Write-Host ('{0}>> {1}{2}' -f $Global:RGBs.Cyan.fg, $label, $trailingSpaces) }
        Elseif ($i -eq ($currentListLength)) { Write-Host ('{0}   {1}{2}' -f $Global:RGBs.Yellow.fg, $label, $trailingSpaces) }
        Else { Write-Host ('   {0}{1}' -f $label, $trailingSpaces) }
      }
    }
  
    while ($true) {
      printMenuWithCurrentSelectionHighlighted
    
      # Read user input
      $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

      # Handle trigger key selection
      for ($i = 0; $i -le $currentListLength; $i++) {
        If ($currentList[$i].trigger -and ($currentList[$i].trigger -eq $key.Character.ToString().ToUpper())) { 
          $currentSelection = $i
          break ListSelectionLoop
        }
      }
    
      # Handle arrow key navigation
      switch ($key.VirtualKeyCode) {
        13 { break ListSelectionLoop }                                                                  # Enter key
        37 {
          If ( $isOnlyOneList ) { 
            $currentSelection = $currentListLength 
            break ListSelectionLoop 
          }
          $listStartIndex = [Math]::Max(0, $listStartIndex - $menuHeight + 1) 
          continue ListSelectionLoop
        }                                                                                               # Left arrow
        38 { $currentSelection = [Math]::Max(0, $currentSelection - 1) }                                # Up arrow
        39 {
          If ( $isOnlyOneList ) { 
            $currentSelection = $currentListLength 
            break ListSelectionLoop 
          }
          $listStartIndex = [Math]::Min($listStartIndex + $menuHeight - 1, $options.Length - $menuHeight) 
          continue ListSelectionLoop
        }                                                                                               # Right arrow
        40 { $currentSelection = [Math]::Min($currentListLength, $currentSelection + 1) }               # Down arrow
        default {
          $currentSelection = $currentListLength 
          break ListSelectionLoop 
        }                                                                                               # Any other key
      }
    }
  }
  printMenuWithCurrentSelectionHighlighted

  $selectedOption = $currentList[$currentSelection] 
  If ($currentSelection -eq $currentListLength) { Write-Cancel }
  Else { Write-Host ("`n{0}Executing..." -f $Global:RGBs.Cyan.fg) }
  
  $Host.UI.RawUI.CursorSize = $initialCursorSize
  $selectedOption.action.Invoke()
}
