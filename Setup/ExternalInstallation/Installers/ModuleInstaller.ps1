class ModuleElement { [string]$name; [object[]]$arguments }
$modules = @(
  [ModuleElement]@{name = 'posh-git' ; arguments = @($false, $false, $true) } # Arguments: [bool]$ForcePoshGitPrompt, [bool]$UseLegacyTabExpansion, [bool]$EnableProxyFunctionExpansion
)


function Import-Modules {
  foreach ($module in $modules) {
    $name = $module.name
    $arguments = $module.arguments
    If (-not (Get-Module -ListAvailable -Name $name)) { Install-Module -Name $name }
    If (Get-Module -ListAvailable -Name $name) { Import-Module -Name $name -ArgumentList $arguments }
  }
}

# Import-Module -Name posh-git -ArgumentList @($false, $false, $true)
# Install-Module -Name posh-git
