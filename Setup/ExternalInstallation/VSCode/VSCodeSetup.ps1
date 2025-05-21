
$RESOURCES_PATH = Join-Path $PSScriptRoot 'Resources'

function Set-ResourcesPath {
  If (-Not (Test-Path -Path $RESOURCES_PATH)) { New-Item -ItemType Directory -Path $RESOURCES_PATH -Force | Out-Null }
}
Set-ResourcesPath


function Test-ResourceExists {
  param ([Parameter(Mandatory)][string]$resourceName)
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath $resourceName
  Return Test-Path -Path $resourceFilePath
}

function Confirm-ResourceCreated {
  param ([Parameter(Mandatory)][string]$resourceName)
  If (Test-ResourceExists -resourceName $resourceName) { Write-Success ('Successfully created resource: {0}' -f (color_focus $resourceName)) }
  Else { Write-Fail ('Failed to create resource: {0}' -f (color_focus $resourceName)) }
}


function Remove-Resource {
  param ([Parameter(Mandatory)][string]$resourceName)
  If (-not (Test-ResourceExists -resourceName $resourceName)) { Return $true }

  Write-Info ('Resource already exists: {0}' -f (color_focus $resourceName))

  If (-not (Confirm-Action -Prompt "Removing resource `'$resourceName`' to create new instance")) {
    Write-Cancel -additionalMessage:$('{0}{1} not removed' -f (color_focus $resourceName), $Global:RGB_FAIL.fg )
    Return $false
  }

  Write-Info ('Removing resource: {0}' -f (color_focus $resourceName))
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath $resourceName
  Remove-Item -Path $resourceFilePath -Recurse -Force

  If (Test-ResourceExists -resourceName $resourceName) {
    Write-Fail ('Failed to remove resource: {0}' -f (color_focus $resourceName))
    Return $false
  }

  Write-Success ('Successfully removed resource: {0}' -f (color_focus $resourceName))
  Return $true
}


function Save-Resource {
  param ([Parameter(Mandatory)][string]$resourceName, [Parameter(Mandatory)]$content)
  Write-Info ('Adding resource {0}' -f (color_focus $resourceName))
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath "$resourceName"
  If (-not (Remove-Resource -resourceName $resourceName)) { Return Write-Cancel -additionalMessage:$('{0}{1} not overwritten' -f (color_focus $resourceName), $Global:RGB_FAIL.fg ) }

  $content | Out-File -FilePath $resourceFilePath -Force
  Confirm-ResourceCreated -resourceName $resourceName
}


function Copy-Resource {
  param ( [Parameter(Mandatory)][string]$resourceName )
  $resourceToCopyPath = "$env:APPDATA\Code\User\$resourceName"

  Write-Info ('Copying VS Code resource {0}' -f (color_focus $resourceName))

  If (-not (Test-Path -Path $resourceToCopyPath)) { Write-Fail ('Failed to copy {0}{1}, because the resource was not found' -f (color_focus $resourceName), $Global:RGB_FAIL.fg ) }
  If (-not (Remove-Resource -resourceName $resourceName)) { Return Write-Cancel -additionalMessage:$('{0}{1} not overwritten' -f (color_focus $resourceName), $Global:RGB_FAIL.fg ) }

  Write-Info ('Copying resource {0}' -f (color_focus $resourceName))
  Copy-Item -Path $resourceToCopyPath -Destination $RESOURCES_PATH -Recurse -Force
  Confirm-ResourceCreated -resourceName $resourceName
}


function Save-VSCodeExtensionListToFile {
  $extensionList = code --list-extensions
  Save-Resource -resourceName 'VSCodeExtensions.txt' -content $extensionList
}


function Copy-VSCodeSettings { Copy-Resource -resourceName 'settings.json' }


function Copy-VSCodeKeybindings { Copy-Resource -resourceName 'keybindings.json' }


function Copy-VSCodeSnippets { Copy-Resource -resourceName 'snippets' }


function Backup-VsCodeResources {
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code settings.`n`tDo you want to precede?") { Copy-VSCodeSettings }
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code keybindings.`n`tDo you want to precede?") { Copy-VSCodeKeybindings }
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code snippets.`n`tDo you want to precede?") { Copy-VSCodeSnippets }
  If (Confirm-Action -Prompt "`nCreating resource-backup of VS Code extensions-list.`n`tDo you want to precede?") { Save-VSCodeExtensionListToFile }
}
Add-ToFunctionList -category 'Setup' -name 'Backup-VsCodeResources' -value 'Create backup of VS Code resources'
