
$RESOURCES_PATH = Join-Path $PSScriptRoot "Resources"

function Set-ResourcesPath {
  if (-Not (Test-Path -Path $RESOURCES_PATH)) { New-Item -ItemType Directory -Path $RESOURCES_PATH -Force | Out-Null }
}
Set-ResourcesPath


function Test-ResourceExists {
  param ([Parameter(Mandatory)][string]$resourceName)
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath $resourceName
  Return Test-Path -Path $resourceFilePath
}

function Confirm-ResourceCreated {
  param ([Parameter(Mandatory)][string]$resourceName)
  if (Test-ResourceExists -resourceName $resourceName) { OUT $(PE -txt:"Successfully created resource `'$resourceName`'" -fg:$Global:colors.Green) }
  else { OUT $(PE -txt:"Failed to create resource `'$resourceName`'" -fg:$Global:colors.Red) }  
}


function Remove-Resource {
  param ([Parameter(Mandatory)][string]$resourceName)
  if (-not (Test-ResourceExists -resourceName $resourceName)) { return $true}

  OUT $(PE -txt:"Resource `'$resourceName`' already exist`n" -fg:$Global:colors.Cyan)
  
  if (-not (Confirm-Action -Prompt "Removing resource `'$resourceName`' to create new instance `n`tDo you want to precede?")) { 
    OUT $(PE -txt:"Cancelling... `'$resourceName`' not overwritten" -fg:$Global:colors.Cyan) 
    return $false
  } 
  
  OUT $(PE -txt:"Removing..." -fg:$Global:colors.Cyan)
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath $resourceName
  Remove-Item -Path $resourceFilePath -Recurse -Force 

  if (Test-ResourceExists -resourceName $resourceName) { 
    OUT $(PE -txt:"Failed to remove resource `'$resourceName`'" -fg:$Global:colors.Red) 
    return $false
  }

  OUT $(PE -txt:"Successfully removed resource `'$resourceName`'" -fg:$Global:colors.Green)
  return $true
}


function Save-Resource {
  param ([Parameter(Mandatory)][string]$resourceName, [Parameter(Mandatory)]$content)
  OUT $(PE -txt:"`nAdding resource `'$resourceName`'" -fg:$Global:colors.Cyan)
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath "$resourceName"
  if (-not (Remove-Resource -resourceName $resourceName)) { Return OUT $(PE -txt:"Cancelling... `'$resourceName`' not overwritten" -fg:$Global:colors.Cyan) }
    
  $content | Out-File -FilePath $resourceFilePath -Force
  Confirm-ResourceCreated -resourceName $resourceName
}


function Copy-Resource {
  param ( [Parameter(Mandatory)][string]$resourceName )
  $resourceToCopyPath = "$env:APPDATA\Code\User\$resourceName"
  
  OUT $(PE -txt:"`nCopying VS Code resource `'$resourceName`'" -fg:$Global:colors.Cyan)
  
  if (-not (Test-Path -Path $resourceToCopyPath)) {OUT $(PE -txt:"Failed to copy `'$resourceName`', because the resource was not found" -fg:$Global:colors.Red) }
  if (-not (Remove-Resource -resourceName $resourceName)) { Return OUT $(PE -txt:"Cancelling... `'$resourceName`' not overwritten" -fg:$Global:colors.Cyan) }
  
  OUT $(PE -txt:"Copying..." -fg:$Global:colors.Cyan)
  Copy-Item -Path $resourceToCopyPath -Destination $RESOURCES_PATH -Recurse -Force 
  Confirm-ResourceCreated -resourceName $resourceName
}


function Save-VSCodeExtensionListToFile {
  $extensionList = code --list-extensions
  Save-Resource -resourceName "VSCodeExtensions.txt" -content $extensionList
}
  

function Copy-VSCodeSettings { Copy-Resource -resourceName "settings.json" }


function Copy-VSCodeKeybindings { Copy-Resource -resourceName "keybindings.json" }


function Copy-VSCodeSnippets { Copy-Resource -resourceName "snippets" }


function Backup-VsCodeResources {
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code settings.`n`tDo you want to precede?") { Copy-VSCodeSettings }
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code keybindings.`n`tDo you want to precede?") { Copy-VSCodeKeybindings }
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code snippets.`n`tDo you want to precede?") { Copy-VSCodeSnippets }
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code extensions-list.`n`tDo you want to precede?") { Save-VSCodeExtensionListToFile }
}
Add-ToFunctionList -category "Setup" -name 'Backup-VsCodeResources' -value 'Create backup of VS Code resources'