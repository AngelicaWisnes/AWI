

# CHANGE THE FOLLOWING ARRAY:
$SYSTEM_PROJECTS = @( )

If ($SYSTEM_PROJECTS.Count -gt 0) { $SYSTEM_PROJECTS = @( $allProjects; ) + $SYSTEM_PROJECTS }





<#
THE FOLLOWING IS FOR TESTING PURPOSES

$SYSTEM_PROJECTS_TEST = @( 
  [PROJECT]@{
    type           = [ProjectType]::STANDARD
    name           = 'AWI - Personal PowerShell-tool'
    repo           = 'AWI'
    branch         = 'main'
    useDotNetIde   = 0
    webs           = ''
    stdSctript     = $true
    customScript   = $null
    nestedProjects = @()
  };

  [PROJECT]@{
    type           = [ProjectType]::STANDARD
    name           = 'Test number 1'
    repo           = 'random-repo-name'
    branch         = 'random-branch-name'
    useDotNetIde   = 0
    webs           = 'https://www.github.com/full-url-to-this-repo'
    stdSctript     = $false
    customScript   = $null
    nestedProjects = @()
  };
  
  [PROJECT]@{
    type           = [ProjectType]::MULTIPLE
    name           = 'Test number 2'
    repo           = ''
    branch         = ''
    useDotNetIde   = 0
    webs           = '
    https://www.figma.com/ 
    https://www.github.com/full-url-to-this-repo
    '
    stdSctript     = $false;
    customScript   = $null
    nestedProjects = @($allProjects;
      [PROJECT]@{
        type           = [ProjectType]::STANDARD
        name           = 'Sub-project 1'
        repo           = 'random-repo-name-for-this-subproject'
        branch         = 'random-branch-name-for-this-subproject'
        useDotNetIde   = 0
        webs           = 'https://www.github.com/full-url-to-this-repo'
        stdSctript     = $true
        customScript   = $null
        nestedProjects = @()
      };

      [PROJECT]@{
        type           = [ProjectType]::STANDARD
        name           = 'Sub-project 2'
        repo           = 'random-repo-name-for-this-subproject'
        branch         = 'random-branch-name-for-this-subproject'
        useDotNetIde   = 0
        webs           = 'https://www.github.com/full-url-to-this-repo'
        stdSctript     = $false
        customScript   = { _pro_Ready }
        nestedProjects = @()
      };

      [PROJECT]@{
        type           = [ProjectType]::STANDARD
        name           = 'Sub-project 3'
        repo           = 'random-repo-name-for-this-subproject'
        branch         = 'Ref-XXX'
        useDotNetIde   = 0
        webs           = 'https://www.github.com/full-url-to-this-repo'
        stdSctript     = $false
        customScript   = { _pro_Merged 'name-of-old-branch (Ref-XXX)' 'name-of-new-branch (Ref-XXX is merged into this one)' }
        nestedProjects = @()
      };
    )
  };
)
If ($SYSTEM_PROJECTS_TEST.Count -gt 0) { $SYSTEM_PROJECTS_TEST = @( $global:allProjects; ) + $SYSTEM_PROJECTS_TEST }
#>
