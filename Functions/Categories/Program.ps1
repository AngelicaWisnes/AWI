
##############################
# Program-related functions #
##############################
function ide_autoChoose {
  <#
  TODO: Create a dynamic choosing-agorithm for opening the best IDE for (parameterized)-"current directory", 
  based on the content of said directory
  
  Examples: 
  If directory contains a yarn.lock-file, or a file with extention ".js", ".jsx", ".ts", ".tsx", then open ide_JavaScript
  elseif directory contains ".sln", then open ide_dotNet
  Else open ide_vsCode
  #>
}

function Open-StartupFolders {
  Invoke-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
  Invoke-Item "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Startup"
}
Set-Alias su Open-StartupFolders
Add-ToFunctionList -category 'Program' -name 'su' -value 'Open Startup Folders'


function ide_dotNet { _startIDE $global:MY_DOTNET_IDE }
Set-Alias dn ide_dotNet
Add-ToFunctionList -category 'Program' -name 'dn' -value 'Open the dotNET-IDE'


function ide_javaScript { _startIDE $global:MY_JS_IDE }
Set-Alias js ide_javaScript
Add-ToFunctionList -category 'Program' -name 'js' -value 'Open the JavaScript-IDE'


function ide_vsCode { code . }
Set-Alias c. ide_vsCode
Add-ToFunctionList -category 'Program' -name 'c.' -value 'Open VS Code in current dir'


function ide_vsCode_NewFile { code -n NewFile }
Set-Alias cn ide_vsCode_NewFile
Add-ToFunctionList -category 'Program' -name 'cn' -value 'Open new file in VS Code'


function o { 
  If ($args.Length -eq 0) { Invoke-Item . }
  Else { Invoke-Item $args }
}
Add-ToFunctionList -category 'Program' -name 'o' -value 'Open current directory'
Add-ToFunctionList -category 'Program' -name 'o args' -value 'Open args'


Set-Alias open Invoke-Item
Add-ToFunctionList -category 'Program' -name 'open' -value 'Invoke-Item'


function startNewBrowser {
  # Args must be a string, and specialcharacters must be escaped
  Start-Process $global:MY_BROWSER -ArgumentList "--new-window", "$args" 
}
Set-Alias snb startNewBrowser
Add-ToFunctionList -category 'Program' -name 'snb' -value 'Start new browser'


function _startIDE {
  param( [Parameter(Mandatory)][string]$IDE )
  $currentPath = Get-FullPath
  Start-Process $IDE -ArgumentList "$currentPath" 
}
