

###########################
# System-related projects #
###########################

enum ProjectType { ALL ; MULTIPLE ; STANDARD }
enum IdeChoice { AUTO ; NONE; VSCODE ; DOTNET ; JS } # TODO: This is currently not in use. Implement the auto-choosing function first

# $ides = [IdeChoice]::AUTO, [IdeChoice]::NONE, [IdeChoice]::VSCODE, [IdeChoice]::DOTNET, [IdeChoice]::JS
# switch ($ides) {
#   AUTO { "It's AUTO"; continue } # Match-alternative 1
#   ([IdeChoice]::NONE) { "It's NONE" ; continue } # Match-alternative 2
# }


class PROJECT {
  [enum]$type;
  [string]$name; 
  [string]$repo; 
  [string]$branch; 
  [int]$useDotNetIde;
  [string]$webs; 
  [bool]$stdSctript;
  [scriptblock]$customScript; 
  [array]$nestedProjects;
} 


$global:allProjects = [PROJECT]@{ 
  type           = [ProjectType]::ALL
  name           = 'All of the following'
  repo           = ''
  branch         = ''
  useDotNetIde   = 0
  webs           = ''
  stdSctript     = $false
  customScript   = { For ($i = 1; $i -lt $projects.length; $i++) { pro -projects $projects -decision $i; } } 
  nestedProjects = @()
};

