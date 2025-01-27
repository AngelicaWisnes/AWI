
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
  If (Test-ResourceExists -resourceName $resourceName) { Write-Success ('Successfully created resource: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName ) }
  Else { Write-Fail ('Failed to create resource: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName ) }
}


function Remove-Resource {
  param ([Parameter(Mandatory)][string]$resourceName)
  If (-not (Test-ResourceExists -resourceName $resourceName)) { Return $true }

  Write-Info ('Resource already exists: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName )

  If (-not (Confirm-Action -Prompt "Removing resource `'$resourceName`' to create new instance")) {
    Write-Info ('Cancelling... {0}{1}{2} not removed' -f (cfg $Global:RGBs.MintGreen), $resourceName, (cfg $Global:RGBs.Cyan) )
    Return $false
  }

  Write-Info ('Removing resource: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName )
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath $resourceName
  Remove-Item -Path $resourceFilePath -Recurse -Force

  If (Test-ResourceExists -resourceName $resourceName) {
    Write-Fail ('Failed to remove resource: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName )
    Return $false
  }

  Write-Success ('Successfully removed resource: {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName )
  Return $true
}


function Save-Resource {
  param ([Parameter(Mandatory)][string]$resourceName, [Parameter(Mandatory)]$content)
  Write-Info ('Adding resource {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName )
  $resourceFilePath = Join-Path -Path $RESOURCES_PATH -ChildPath "$resourceName"
  If (-not (Remove-Resource -resourceName $resourceName)) { Return Write-Info ('Cancelling... {0}{1}{2} not overwritten' -f (cfg $Global:RGBs.MintGreen), $resourceName, (cfg $Global:RGBs.Cyan) ) }

  $content | Out-File -FilePath $resourceFilePath -Force
  Confirm-ResourceCreated -resourceName $resourceName
}


function Copy-Resource {
  param ( [Parameter(Mandatory)][string]$resourceName )
  $resourceToCopyPath = "$env:APPDATA\Code\User\$resourceName"

  Write-Info ('Copying VS Code resource {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName )

  If (-not (Test-Path -Path $resourceToCopyPath)) { Write-Fail ('Failed to copy {0}{1}{2}, because the resource was not found' -f (cfg $Global:RGBs.MintGreen), $resourceName, (cfg $Global:RGBs.Red) ) }
  If (-not (Remove-Resource -resourceName $resourceName)) { Return Write-Info ('Cancelling... {0}{1}{2} not overwritten' -f (cfg $Global:RGBs.MintGreen), $resourceName, (cfg $Global:RGBs.Cyan) ) }

  Write-Info ('Copying resource {0}{1}' -f (cfg $Global:RGBs.MintGreen), $resourceName )
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
