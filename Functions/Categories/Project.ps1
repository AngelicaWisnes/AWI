
#############################
# Project-related functions #
#############################
function pro {
  param(
    [array]$projects = $SYSTEM_PROJECTS,
    [int]$decision = -1
  )
  If ( $projects.Count -eq 0 ) { Return Write-Fail 'The project-list is empty' }

  # If decision is '-1', try to get a decision. If it still is '-1' after deciding, then Return a cancel-statement
  Write-Info 'Quick-launching project...'
  If ( $decision -eq -1 ) { $decision = _pro_printChoicesAndGetDecision($projects) }
  If ( $decision -eq -1 ) { Return Write-Info 'Cancelled quick-launch' }

  $chosen = $projects[$decision]
  Write-Info "Launching project '$($chosen.name)'..."

  If ($($chosen.webs).Length -gt 0) { startNewBrowser $chosen.webs }
  If ($chosen.stdScript) { _pro_newPsStdActions -repo $chosen.repo -branch $chosen.branch -useDotNetIde $chosen.useDotNetIde }
  If ($null -ne $chosen.customScript) { Invoke-Command -ScriptBlock $chosen.customScript }
  If ($chosen.nestedProjects) { pro -projects $chosen.nestedProjects }
}
Add-ToFunctionList -category 'Project' -name 'pro' -value 'Quick-launch current projects'


function proClean {
  param(
    [array]$projects = $SYSTEM_PROJECTS_TEST,
    [int]$decision = -1
  )

  # If decision is '-1', try to get a decision. If it still is '-1' after deciding, then Return a cancel-statement
  Write-Host ("`n{0}Cleanup quick-launch project..." -f $Global:RGBs.White.fg)
  If ( $decision -eq -1 ) { $decision = _pro_printChoicesAndGetDecision($projects) }
  If ( $decision -eq -1 ) { Return Write-Info 'Cancelled cleanup' }

  $chosen = $projects[$decision]
  Write-Info "Launching cleanup on '$($chosen.name)'..."

  # Open 'SystemProjects.ps1' to facilitate changes
  code $global:AWI
  code $global:SYSTEM_PROJECTS_PATH

  startNewBrowser (_pro_getWebs -projects @($chosen))

  Write-Info "`n`tNOTE: If the bitbucket pages show '404', `n`tthen that should mean the branch is deleted correctly."
}
Add-ToFunctionList -category 'Project' -name 'proClean' -value 'Cleanup quick-launch projects'


function _pro_getWebs {
  param( [Parameter(Mandatory)][array]$projects )

  $sb = [System.Text.StringBuilder]::new()

  Foreach ($project in $projects) {
    [void]$sb.AppendFormat('{0} ', $project.webs)

    If ($project.type -eq [ProjectType]::STANDARD) {
      [void]$sb.AppendFormat("{0}`n", (_openGitBranchInBrowser_string -repo $project.repo -branch $project.branch))
    }
    If ($project.type -eq [ProjectType]::MULTIPLE) {
      [void]$sb.AppendFormat("{0}`n", (_pro_getWebs -projects $project.nestedProjects))
    }
    #If ($project.type -eq [ProjectType]::ALL) {}

  }
  Return $sb.ToString()
}


function _pro_printChoicesAndGetDecision {
  param( [Parameter(Mandatory)][array]$projects )
  If ($projects.Count -gt 10) { Return _pro_printChoicesAndGetDecision_manualInput($projects) }
  Else { Return _pro_printChoicesAndGetDecision_autoInput($projects) }
}


function _pro_printChoicesAndGetDecision_autoInput {
  param( [Parameter(Mandatory)][array]$projects )
  Write-Host 'These are the available quick-launch-projects:'
  Write-Host ('   [0] ' + $($projects[0].name))
  For ($i = 1; $i -lt $projects.length; $i++) { Write-Host ("   [$i] " + $($projects[$i].name)) }
  Write-Host '   [Any] Cancel '

  # Read input-key, and check If it is a number
  $decision = $Host.UI.RawUI.ReadKey().Character
  $isInteger = ([System.Int32]::TryParse($decision, [ref] ''))
  If (-Not $isInteger) { Return -1 }

  # Adjust number to correlate with bounds of project-array, and check If it is inside bounds
  $decision = (($decision -as [int]) - 48)
  $outOfBounds = (($decision -lt 0) -or ($decision -ge $projects.Length))
  If ($outOfBounds) { Return -1 }

  Return $decision
}

function _pro_printChoicesAndGetDecision_manualInput {
  param( [Parameter(Mandatory)][array]$projects )
  Write-Host 'These are the available quick-launch-projects:'
  Write-Host ('   [0] ' + $($projects[0].name))
  For ($i = 1; $i -lt $projects.length; $i++) { Write-Host ("   [$i] " + $($projects[$i].name)) }
  Write-Host '   [Any] Cancel '

  try {
    $userInput = Read-Host 'Enter your choice'
    If (!$userInput.Length) { throw 'empty input' }

    [int]$decision = $userInput
    If (($decision -lt 0) -or ($decision -ge $projects.Length)) { throw 'out of bounds' }
  }
  catch { Return -1 }

  Return $decision
}


function _pro_Merged {
  param(
    [Parameter(Mandatory)][String]$oldBranch,
    [Parameter(Mandatory)][String]$newBranch
  )
  Write-Info "`n`tNOTE: This branch `n`t`'$oldBranch`' `n`tis merged into `n`t`'$newBranch`'`n"
}


function _pro_Ready { Write-Info "`n`tNOTE: This project is ready for release. `n`tMake sure that all branches are deleted after merge.`n" }


function _pro_newPsStdActions {
  param(
    [Parameter(Mandatory)][String]$repo,
    [Parameter(Mandatory)][String]$branch,
    [int]$useDotNetIde = 0
  )

  Start-NewPowershell {
    param($repo, $branch, $useDotNetIde)
    _pro_stdActions $repo $branch $useDotNetIde
  } ($($repo), $($branch), $($useDotNetIde))
}


function _pro_stdActions {
  param(
    [Parameter(Mandatory)][String]$repo,
    [Parameter(Mandatory)][String]$branch,
    [int]$useDotNetIde = 0
  )

  # Switch to correct repository
  Set-Location $global:DEFAULT_START_PATH\$repo

  # Switch to correct branch
  If ($branch -eq 'BYPASS') { Write-Info "`tNo branch name was provided`n`t" }
  Else { _pro_stdActions_changeBranch $branch }

  # Check status, open bitbucket-repo, and open VS code
  git status
  openGitBranchInBrowser
  If ($useDotNetIde) { ide_dotNet } Else { ide_vsCode }
}



function _pro_stdActions_changeBranch {
  param( [Parameter(Mandatory)][String]$branch )

  Write-Info "Checkout branch: $branch"
  $currentGitBranch = getCurrentGitBranch
  If ($currentGitBranch -ne $branch) {
    If ((Get-GitStatus).Working.length -eq 0 -and (Get-GitStatus).Index.length -eq 0) {
      co $branch
    }
    Else {
      Set-Clipboard -Value $branch
      Write-Fail 'Current branch has unhandled changes. Handle changes before switching to working branch.'
      Write-Info 'Working branch-name is copied to clipboard'
    }
  }
  Else {
    Write-Info "Already on correct branch`n"
  }
}
