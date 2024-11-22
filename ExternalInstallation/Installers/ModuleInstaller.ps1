class ModuleElement {[string]$name; [object[]]$arguments}
$modules = @(
    [ModuleElement]@{name = "posh-git" ; arguments = @($false, $false, $true) } # Arguments: [bool]$ForcePoshGitPrompt, [bool]$UseLegacyTabExpansion, [bool]$EnableProxyFunctionExpansion
)


function Import-Modules {
  foreach ($module in $modules) {
    $name = $module.name
    $arguments = $module.arguments
    if (-not (Get-Module -ListAvailable -Name $name)) { Install-Module -name $name }
    if (Get-Module -ListAvailable -Name $name) { Import-Module -Name $name -ArgumentList $arguments }
  }
}

