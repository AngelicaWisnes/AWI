
#########################
# Git-related functions #
#########################

function Test-IsGitRepo { 
  $isGitRepo = try { 
    git rev-parse --is-inside-work-tree 2>$null -ErrorAction SilentlyContinue 
  }
  catch { $false }
  If (-not $isGitRepo) { Write-Fail 'This is not a git repository' }
  Return $isGitRepo
}


function Invoke-GitAddAllOrArg {
  If (-not (Test-IsGitRepo)) { Return }
  If ($args.Length -eq 0) { git add . }
  Else { git add $args }
  Get-GitStatusStandard
}
Set-Alias a Invoke-GitAddAllOrArg
Add-ToFunctionList -category 'Git' -name 'a' -value 'git add args'


function Get-GitBranchType {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Prompt 'Please choose a branch type:'
  Show-NavigableMenu -menuHeader:'Branch-type' -options:@(
    [NavigableMenuElement]@{trigger = '0'; label = 'feat'; action = { Return 'feat/' } },
    [NavigableMenuElement]@{trigger = '1'; label = 'fix'; action = { Return 'fix/' } },
    [NavigableMenuElement]@{trigger = '2'; label = 'chore'; action = { Return 'chore/' } }
    [NavigableMenuElement]@{trigger = '3'; label = 'experimental'; action = { Return 'experimental/' } }
    [NavigableMenuElement]@{trigger = '4'; label = 'release'; action = { Return 'release/' } }
    [NavigableMenuElement]@{trigger = 'N'; label = 'NONE'; action = { Return '' } }
  )
}
  
  
function Get-GitBranchPrefix {
  If (-not (Test-IsGitRepo)) { Return }
  $systemDependentPrefixes = Get-SystemDependentBranchPrefixes
  If ($systemDependentPrefixes.Count -eq 0) { Return '' }
  Write-Prompt 'Please choose a branch prefix:'
  
  $options = @()
  $systemDependentPrefixes | ForEach-Object {
    $trigger = If ($systemDependentPrefixes.IndexOf($_) -lt 10) { $systemDependentPrefixes.IndexOf($_).ToString() } Else { $null }
    $options += [NavigableMenuElement]@{ trigger = $trigger; label = $_; action = [scriptblock]::Create("Return '$_'") }
  }
  $options += [NavigableMenuElement]@{trigger = 'N'; label = 'NONE'; action = { Return '' } }
  
  Show-NavigableMenu -menuHeader:'Branch-prefix' -options:$options
}


function New-GitBranch {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Initiate 'New branch creation'
  
  $branchType = Get-GitBranchType
  If ($null -eq $branchType) { Return }
  
  $branchPrefix = Get-GitBranchPrefix
  If ($null -eq $branchPrefix) { Return }
  
  $branchNamePrefix = '{0}{1}' -f $branchType, $branchPrefix
  
  Write-Prompt "Preparing 'git checkout -b'. Please enter branch-name" -NoNewline
  Write-Info "`tName-length  $global:FIFTY_CHARS `n`tBranch-name: $branchNamePrefix" -NoNewline
  $branchInput = Get-ColoredInput
  $branchName = $branchNamePrefix + $branchInput

  Write-Info ("Trying: {0}git checkout -b '{1}'`n" -f $Global:RGBs.DarkCyan.fg, $branchName)

  git checkout -b $branchName
}
Set-Alias gcb New-GitBranch
Add-ToFunctionList -category 'Git' -name 'gcb' -value 'git checkout -b'


function Invoke-GitCommit { 
  If (-not (Test-IsGitRepo)) { Return }
  git commit 
}
Set-Alias c Invoke-GitCommit
Add-ToFunctionList -category 'Git' -name 'c' -value 'git commit'


function Invoke-GitCommitWithMessage {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Prompt "Preparing 'git commit -m'. Please enter commit-message" -NoNewline
  Write-Info "`tMessage-length  $global:FIFTY_CHARS `n`tCommit message: " -NoNewline

  $commitMessage = Get-ColoredInput
  Write-Info ("Trying: {0}git commit -m '{1}'`n" -f $Global:RGBs.DarkCyan.fg, $commitMessage)

  git commit -m $commitMessage
}
Set-Alias cm Invoke-GitCommitWithMessage
Add-ToFunctionList -category 'Git' -name 'cm' -value 'git commit -m'


function Invoke-GitCheckout {
  param( [string]$argToCheckout )
  If (-not (Test-IsGitRepo)) { Return }

  If (-not $argToCheckout) {
    Write-Info "No checkout-argument provided. Enter manually:`n`tCheckout-argument: " -NoNewline
    $argToCheckout = Get-ColoredInput
  }

  Write-Info ("Initializing following:`n`t{0}git checkout {1}" -f $Global:RGBs.DarkCyan.fg, $argToCheckout)
  git checkout $argToCheckout
}
Set-Alias co Invoke-GitCheckout
Add-ToFunctionList -category 'Git' -name 'co' -value 'git checkout args'


function Invoke-GitRebase {
  param( [Parameter(Mandatory)][string]$argToRebase )
  If (-not (Test-IsGitRepo)) { Return }

  If (-not $argToRebase) {
    Write-Info "No rebase-argument provided. Enter manually:`n`Rebase-argument: " -NoNewline
    $argToRebase = Get-ColoredInput
  }

  Write-Info ("Initializing following:`n`t{0}git rebase {1}" -f $Global:RGBs.DarkCyan.fg, $argToRebase)
  git rebase $argToRebase
}
Set-Alias gra Invoke-GitRebase
Add-ToFunctionList -category 'Git' -name 'gra' -value 'git rebase args'


function Invoke-GitCheckoutPrevious { 
  If (-not (Test-IsGitRepo)) { Return }
  git checkout - 
}
Set-Alias co- Invoke-GitCheckoutPrevious
Add-ToFunctionList -category 'Git' -name 'co-' -value 'git checkout -'


Set-Alias g git
Add-ToFunctionList -category 'Git' -name 'g' -value 'git'


function Get-CurrentGitBranch { 
  If (-not (Test-IsGitRepo)) { Return }
  git rev-parse --abbrev-ref HEAD 
}
Set-Alias gb Get-CurrentGitBranch
Add-ToFunctionList -category 'Git' -name 'gb' -value 'Get current git branch'


function Get-MasterBranch {
  If (-not (Test-IsGitRepo)) { Return }
  $output = git symbolic-ref --short refs/remotes/origin/HEAD 2>$null
  If ($output) { Return [System.IO.Path]::GetFileName($output.Trim()) }
  Else { Return Write-Host 'Failed to retrieve master branch.' }
}
Set-Alias gmb Get-MasterBranch
Add-ToFunctionList -category 'Git' -name 'gmb' -value 'Get git master branch'


function Get-TotalLineCountInRepo { 
  If (-not (Test-IsGitRepo)) { Return }
  git diff --stat $(git hash-object -t tree /dev/null) -- ":!$Global:AWI\Logo\Images" ":!$Global:AWI\TEMPORARY FILES"
}
Set-Alias glc Get-TotalLineCountInRepo
Add-ToFunctionList -category 'Git' -name 'glc' -value 'Get total line count in repo'


function Invoke-GitCombineCommits {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Initiate "Commit-combination with 'git reset --soft <hash>', to combine all commits done after given hash`n"
  git log -n 3
  Write-Prompt "
  `tPlease provide the commit-hash belonging to the last commit
  `tdone BEFORE the first commit you want to include in this process, according to git log
  `tCommit-Hash: " -NoNewline

  $commitHash = Get-ColoredInput

  Write-Info ("Trying: {0}git reset --soft '{1}'`n" -f $Global:RGBs.DarkCyan.fg, $commitHash)

  git reset --soft $commitHash

  Write-Info "Next steps in the process: `n`t- Create the new commit(s) `n`t- Use the command Invoke-GitPushForce (alias pf)"
}
Set-Alias gcc Invoke-GitCombineCommits
Add-ToFunctionList -category 'Git' -name 'gcc' -value 'Combine previous git commits'


function Remove-CurrentBranch {
  If (-not (Test-IsGitRepo)) { Return }
  $currentGitBranch = Get-CurrentGitBranch
  $masterBranch = Get-MasterBranch
  If ($currentGitBranch -eq $masterBranch) { Return Write-Fail 'Cannot delete master branch' }

  $title = "$(Get-FunctionDefinitionAsString Invoke-GitCheckoutMaster)  git branch -d $currentGitBranch `n  git push origin --delete $currentGitBranch"
  $question = 'Are you sure you want to proceed?'
  $choices = '&Yes', '&No'

  Write-Info 'Trying to run the following commands:' -NoNewline
  $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

  If ($decision -eq 0) {
    Write-Info 'Confirmed'
    Invoke-GitCheckoutMaster
    git branch -d $currentGitBranch
    git push origin --delete $currentGitBranch
  }
  Else { Write-Info 'Cancelled' }
}
Set-Alias rcb Remove-CurrentBranch
Add-ToFunctionList -category 'Git' -name 'rcb' -value 'Delete current git branch (local&remote)'


function Merge-CurrentIntoMaster {
  If (-not (Test-IsGitRepo)) { Return }
  $currentBranch = Get-CurrentGitBranch
  Invoke-GitCheckoutMaster
  git merge $currentBranch
}
Set-Alias gmc Merge-CurrentIntoMaster
Add-ToFunctionList -category 'Git' -name 'gmc' -value 'git merge current into master'


function Merge-Args { 
  If (-not (Test-IsGitRepo)) { Return }
  git merge $args 
}
Set-Alias gma Merge-Args
Add-ToFunctionList -category 'Git' -name 'gme' -value 'git merge args'


function Merge-Master {
  If (-not (Test-IsGitRepo)) { Return }
  $masterBranch = Get-MasterBranch
  git merge $masterBranch
}
Set-Alias gmm Merge-Master
Add-ToFunctionList -category 'Git' -name 'gmm' -value 'git merge master'


function Invoke-GitPull { 
  If (-not (Test-IsGitRepo)) { Return }
  git pull 
}
Set-Alias gpl Invoke-GitPull
Add-ToFunctionList -category 'Git' -name 'gpl' -value 'git pull'


function Invoke-GitPruneAndPull {
  If (-not (Test-IsGitRepo)) { Return }
  Invoke-GitPrune
  Invoke-GitPull
}
Set-Alias gppl Invoke-GitPruneAndPull
Add-ToFunctionList -category 'Git' -name 'gppl' -value 'git gc --prune=now && git pull'


function Reset-Hard { 
  If (-not (Test-IsGitRepo)) { Return }
  git reset --hard 
}
Set-Alias gr Reset-Hard
Add-ToFunctionList -category 'Git' -name 'gr' -value 'git reset --hard'


function Rename-Branch {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Initiate 'Renaming of current branch'
  Write-Prompt 'Please enter new branch-name' -NoNewline
  Write-Info "`tName-length  $global:FIFTY_CHARS `n`tBranch-name: $branchNamePrefix" -NoNewline

  $newBranchName = Get-ColoredInput
  $oldBranchName = Get-CurrentGitBranch

  # Rename local branch.
  git branch -m $newBranchName

  # Delete the old-name remote branch and push the new-name local branch.
  git push origin :$oldBranchName $newBranchName

  # Reset the upstream branch for the new-name local branch.
  git push origin -u $newBranchName
}
Set-Alias grb Rename-Branch
Add-ToFunctionList -category 'Git' -name 'grb' -value 'Rename git branch'


function Invoke-GitCheckoutMaster {
  If (-not (Test-IsGitRepo)) { Return }
  $masterBranch = Get-MasterBranch
  git checkout $masterBranch
}
Set-Alias m Invoke-GitCheckoutMaster
Add-ToFunctionList -category 'Git' -name 'm' -value 'git checkout master/main'


function Open-GitBranchInBrowser {
  param(
    [string]$repo = $(Get-CurrentRepo),
    [string]$currentGitBranch = $(Get-CurrentGitBranch)
  )
  If (-not (Test-IsGitRepo)) { Return }
  Start-Process $global:MY_BROWSER -ArgumentList $(Get-GitBranchUrl -repo $repo -branch $currentGitBranch)
}
Set-Alias ob Open-GitBranchInBrowser
Add-ToFunctionList -category 'Git' -name 'ob' -value 'Open git-branch in browser'


function Get-GitBranchUrl {
  param(
    [Parameter(Mandatory)][string]$repo,
    [Parameter(Mandatory)][string]$branch
  )
  If (-not (Test-IsGitRepo)) { Return }
  If ($global:GIT_BRANCH_URL.Contains('{1}')) { Return $global:GIT_BRANCH_URL -f $repo, $branch }
  Else { Return $global:GIT_BRANCH_URL -f $repo }
}
Set-Alias gbu Get-GitBranchUrl
Add-ToFunctionList -category 'Git' -name 'gbu' -value 'Get url for current git-branch'


function Invoke-GitPush { 
  If (-not (Test-IsGitRepo)) { Return }
  git push 
}
Set-Alias p Invoke-GitPush
Add-ToFunctionList -category 'Git' -name 'p' -value 'git push'


function Invoke-GitPushForce { 
  If (-not (Test-IsGitRepo)) { Return }
  git push --force-with-lease 
}
Set-Alias pf Invoke-GitPushForce
Add-ToFunctionList -category 'Git' -name 'pf' -value 'git push --force-with-lease'


function Invoke-GitPushAndOpenBranchInBrowser {
  If (-not (Test-IsGitRepo)) { Return }
  Invoke-GitPush
  Open-GitBranchInBrowser
}
Set-Alias po Invoke-GitPushAndOpenBranchInBrowser
Add-ToFunctionList -category 'Git' -name 'po' -value 'git push && Open git-branch i browser'


function Set-GitUpstreamAndPush {
  If (-not (Test-IsGitRepo)) { Return }
  $currentGitBranch = Get-CurrentGitBranch
  $title = "`tgit push --set-upstream origin $currentGitBranch"
  $question = 'Are you sure you want to proceed?'
  $choices = '&Yes', '&No'

  Write-Info 'Trying to run the following command:' -NoNewline
  $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

  If ($decision -eq 0) {
    Write-Info 'Confirmed'
    git push --set-upstream origin $currentGitBranch
  }
  Else { Write-Info 'Cancelled' }
}
Set-Alias pu Set-GitUpstreamAndPush
Add-ToFunctionList -category 'Git' -name 'pu' -value 'git push --set-upstream origin'


function Invoke-GitPrune { 
  If (-not (Test-IsGitRepo)) { Return }
  git gc --prune=now 
}
Set-Alias gpr Invoke-GitPrune
Add-ToFunctionList -category 'Git' -name 'gpr' -value 'git gc --prune=now'


function Invoke-GitQuickCommitAll {
  If (-not (Test-IsGitRepo)) { Return }
  git add .
  git commit -m 'Various small changes'
}
Set-Alias qca Invoke-GitQuickCommitAll
Add-ToFunctionList -category 'Git' -name 'qca' -value 'Quick-Commit all'


function Get-GitStatusStandard {
  If (-not (Test-IsGitRepo)) { Return }
  git fetch
  git status
}
Set-Alias s Get-GitStatusStandard
Add-ToFunctionList -category 'Git' -name 's' -value 'git status'


function Invoke-GitBranchHandler {
  If (-not (Test-IsGitRepo)) { Return }

  $options = @(
    [NavigableMenuElement]@{trigger = 'C'; label = 'Checkout branch'; action = { Invoke-GitChooseBranch } },
    [NavigableMenuElement]@{trigger = 'R'; label = 'Rebase local branch'; action = { Invoke-GitRebaseLocalBranch } },
    [NavigableMenuElement]@{trigger = 'D'; label = 'Delete local branches that have been deleted from remote'; action = { Remove-LocalBranchesDeletedFromRemote } },
    [NavigableMenuElement]@{trigger = 'N'; label = 'Create new local branch'; action = { New-GitBranch } },
    [NavigableMenuElement]@{trigger = 'S'; label = 'System dependent branch handling'; action = { Get-SystemDependentGitCheckouts } }
  )
  Show-NavigableMenu -menuHeader:'Branch handling' -options:$options
}
Set-Alias b Invoke-GitBranchHandler
Add-ToFunctionList -category 'Git' -name 'b' -value 'Git handle branches'


function Invoke-GitChooseBranch {
  If (-not (Test-IsGitRepo)) { Return }

  $localBranchNamesAsList = (git branch --format="%(refname:short)").Split("`n")
  $numberOfBranches = $localBranchNamesAsList.Length
  If ($numberOfBranches -eq 0) { Return Write-Fail 'No local branches found' }

  $options = @()
  $localBranchNamesAsList | ForEach-Object {
    $trigger = If ($localBranchNamesAsList.IndexOf($_) -lt 10) { $localBranchNamesAsList.IndexOf($_).ToString() } Else { $null }
    $options += [NavigableMenuElement]@{ trigger = $trigger; label = $_; action = [scriptblock]::Create("Invoke-GitCheckout '$_'") }
  }
  $options += [NavigableMenuElement]@{ trigger = 'R'; label = 'Choose remote branch'; action = { Invoke-GitChooseRemoteBranch } }
  $options += [NavigableMenuElement]@{ trigger = 'M'; label = 'Enter branch name manually'; action = { Invoke-GitCheckout } }
  
  Show-NavigableMenu -menuHeader:'Checkout branch' -options:$options
}


function Invoke-GitChooseRemoteBranch {
  If (-not (Test-IsGitRepo)) { Return }

  $remoteBranchNamesAsList = (git branch -r --format="%(refname:short)").Split("`n") 
  | Where-Object { $_ -ne 'origin' } 
  | ForEach-Object { $_ -replace '^origin/', '' }
  $numberOfBranches = $remoteBranchNamesAsList.Length
  If ($numberOfBranches -eq 0) { Return Write-Fail 'No remote branches found' }

  $options = @()
  $remoteBranchNamesAsList | ForEach-Object {
    $options += [NavigableMenuElement]@{ trigger = $null; label = $_; action = [scriptblock]::Create("Invoke-GitCheckout '$_'") }
  }
  $options += [NavigableMenuElement]@{ trigger = 'M'; label = 'Enter branch name manually'; action = { Invoke-GitCheckout } }
  
  Show-NavigableMenu -menuHeader:'Checkout remote branch' -options:$options
}


function Invoke-GitRebaseLocalBranch {
  If (-not (Test-IsGitRepo)) { Return }

  $localBranchNamesAsList = (git branch --format="%(refname:short)").Split("`n")
  $numberOfBranches = $localBranchNamesAsList.Length
  If ($numberOfBranches -eq 0) { Return Write-Fail 'No local branches found' }

  $options = @()
  $localBranchNamesAsList | ForEach-Object {
    $trigger = If ($localBranchNamesAsList.IndexOf($_) -lt 10) { $localBranchNamesAsList.IndexOf($_).ToString() } Else { $null }
    $options += [NavigableMenuElement]@{ trigger = $trigger; label = $_; action = [scriptblock]::Create("Invoke-GitRebase '$_'") }
  }
  $options += [NavigableMenuElement]@{ trigger = 'M'; label = 'Enter branch name manually'; action = { Invoke-GitRebase } }
  
  Show-NavigableMenu -menuHeader:'Rebase local branch' -options:$options
}


function Remove-LocalBranchesDeletedFromRemote {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Initiate 'Deletion of local branches that have been deleted from remote'

  git fetch --prune *> $null 2>&1

  Write-Info 'These are the remote deleted branches:' -NoNewline
  $branches = git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | ForEach-Object {
    $parts = $_ -split ' '
    If ($parts[1] -eq '[gone]') {
      $parts[0]
    }
  }

  If ($branches.length -eq 0) { Return Write-Info "`tNone" -NoNewline }
  $branches | ForEach-Object { Write-Info "`t$_" -NoNewline }

  Write-Info 'Continue deleting these branches from local [Y/N (Default)]: ' -NoNewline
  $userInput = $Host.UI.RawUI.ReadKey().Character.ToString()
  If ($userInput.ToUpper() -eq 'Y') {
    Write-Host
    $branches | ForEach-Object { git branch -D $($_) }
  }
  Else { Write-Cancel }
}
Set-Alias dlb Remove-LocalBranchesDeletedFromRemote


function Get-CoverageReport {
  param([string]$focus, [switch]$onlyIncreasable = $false)
  If (-not (Test-IsGitRepo)) { Return }
  $jestOutput = pnpm jest --coverage --coverageReporters=text --silent
  
  $coverageHeader = $jestOutput | Select-String -Pattern '^File\s+\|'
  $coverageLineDivider = $jestOutput | Select-String -Pattern '^-{3,}' | Select-Object -First 1
  $coverageList = $jestOutput | Select-String -Pattern '(^All files\s+\||^\s*\S+\.\S+\s+\|\s+\d+)' | Where-Object { $_ -notmatch '^\*\*' }

  $firstLineColumnLength = ($coverageList[0].Matches[0].Value).Split('|')[0].Length
  $totalNameLength = $coverageList | ForEach-Object { $_.Matches[0].Value.Split('|')[0].Trim().Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
  $numberOfSpacesToBeRemoved = $firstLineColumnLength - ($totalNameLength + 5)

  $shortDivider = "`t|-" + ($coverageLineDivider -replace "-{$numberOfSpacesToBeRemoved}\|", '|') + '|'
  $shortHeader = "`t| " + ($coverageHeader -replace " {$numberOfSpacesToBeRemoved}\|", '|') + '|'
  $shortContent = $coverageList | ForEach-Object { $_ -replace " {$numberOfSpacesToBeRemoved}\|", '|' }
  
  $frame = ('{0}|' -f $Global:RGBs.Jade.fg)
  
  # Print the coverage report in the specified order
  $sb = [System.Text.StringBuilder]::new()
  [void]$sb.Append(("`n{0}{1}`n{0}{2}`n{0}{3}" -f $Global:RGBs.Jade.fg, ($shortDivider -replace '-', '¯'), $shortHeader, $shortDivider))
  Foreach ( $line in $shortContent ) {
    $lineSegments = $line.Split('|')
    $coverageSegments = $lineSegments[1..4]
    $isFullyCovered = ($coverageSegments | ForEach-Object { [double]$_ -gt 90 }) -notcontains $false
    If ($onlyIncreasable) { continue }
    $isAllFilesLine = $line -match 'All files'
    
    function Get-FileColor { 
      param([string]$element) 
      If ($focus -and $element -match $focus) { Return  $Global:RGBs.Yellow }
      If ($isFullyCovered) { Return  $Global:RGBs.Jade }
      If ($isAllFilesLine) { Return  $Global:RGBs.LightSlateBlue }
      Return  $Global:RGBs.DeepPink 
    }
    
    function Get-CoverageColor { 
      param([string]$element) 
      If ([double]$element -gt 90) { Return  $Global:RGBs.Jade }
      If ([double]$element -lt 60) { Return  $Global:RGBs.Orange }
      If ($isAllFilesLine) { Return  $Global:RGBs.LightSlateBlue }
      Return  $Global:RGBs.DeepPink
    }
    
    [void]$sb.Append(("`n`t$frame "))
    [void]$sb.Append(('{0}{1}{2}' -f (Get-FileColor $lineSegments[0]).fg, $lineSegments[0], $frame))
    $coverageSegments | ForEach-Object { [void]$sb.Append(('{0}{1}{2}' -f (Get-CoverageColor $_).fg, $_, $frame)) }
    [void]$sb.Append(('{0}{1}{2}' -f $Global:RGBs.DeepPink.fg, $lineSegments[5], $frame))

    If ($isAllFilesLine) { [void]$sb.Append(("`n{0}{1}" -f $Global:RGBs.Jade.fg, $shortDivider)) }
  }
  [void]$sb.Append(("`n{0}{1}{2}" -f $Global:RGBs.Jade.fg, ($shortDivider -replace '-', '.' ), $Global:RGB_RESET))

  $sb.ToString()
}
Set-Alias gcr Get-CoverageReport
Add-ToFunctionList -category 'Git' -name 'gcr' -value 'Get jest coverage report'

function Set-TokenizedRemoteURL {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Info "Setting remote URL with personal access token.
  `tGo to GitHub -> Profile -> Settings -> Developer Settings -> Personal access token, and generate a token.
  `tEnter token: " -NoNewline

  $token = Get-ColoredInput
  git remote set-url origin "https://$token@github.com/AngelicaWisnes/AWI"
}
Set-Alias stru Set-TokenizedRemoteURL
Add-ToFunctionList -category 'Git' -name 'stru' -value 'Set Remote URL w/personal access token'

function Set-GitEditorToVSCode { 
  If (-not (Test-IsGitRepo)) { Return }
  git config --global core.editor 'code --wait --new-window' 
}
Add-ToFunctionList -category 'Git' -name 'Set-GitEditorToVSCode' -value 'Set git editor to VSCode'
  
function Edit-GitConfig { 
  If (-not (Test-IsGitRepo)) { Return }
  git config --global --edit 
}
Add-ToFunctionList -category 'Git' -name 'Edit-GitConfig' -value 'Edit global git config'


function Get-PnpmBiomeLintList {
  $output = pnpm biome lint 2>&1 | Out-String -Stream
  $filteredOutput = $output -split "`n" | Where-Object { $_.Length -ge 3 -and $_[2] -ne ' ' }
  
  $results = @()
  $maxShortPathLength = 0
  
  for ($i = 0; $i -lt $filteredOutput.Length; $i++) {
    $fullPath = ''
    $shortPath = ''
    $message = ''
    
    If ($filteredOutput[$i] -match '^(?<path>\S+:\d+:\d+)') {
      $fullPath = $matches['path']
      $shortPath = $fullPath -replace '^.+\\', ''
      $maxShortPathLength = [Math]::Max($maxShortPathLength, $shortPath.Length)
      
      If ($i + 1 -lt $filteredOutput.Length) { $message = $filteredOutput[++$i] }
      Else { $message = 'No message provided' }
    }
    
    If ($fullPath -ne '' -and $shortPath -ne '' -and $message -ne '') {
      $results += [pscustomobject]@{ fullPath = $fullPath; shortPath = $shortPath; message = $message }
    }
  }

  If ($results.Count -eq 0) { Return Write-Success 'No biome lint issues found' }

  $options = @()
  $results | ForEach-Object {
    $goToPath = $_.fullPath
    $options += [NavigableMenuElement]@{
      label  = $_.shortPath.PadRight($maxShortPathLength) + $_.message
      action = [scriptblock]::Create("code --goto '$goToPath'")
    }
  }
  
  Show-NavigableMenu -menuHeader:'Pnpm Biome Lint' -options:$options
}
Set-Alias pbl Get-PnpmBiomeLintList
Add-ToFunctionList -category 'Git' -name 'pbl' -value 'Get navigable pnpm biome lint list'


function Get-PnpmTypeCheckList {
  $output = pnpm tsc -b --pretty 2>&1 | Out-String -Stream | ForEach-Object { $_ -replace "`e\[[\d;]*[a-zA-Z]", '' }
  $filteredOutput = $output -split "`n" | Where-Object { $_.Length -ge 3 -and $_[0] -ne ' ' }
  
  $results = @()
  $maxShortPathLength = 0

  for ($i = 0; $i -lt $filteredOutput.Length; $i++) {
    $fullPath = ''
    $shortPath = ''
    $message = ''
    
    If ($filteredOutput[$i] -match '^(?<path>\S+:\d+:\d+)') {
      $fullPath = $matches['path']
      $shortPath = $fullPath -replace '^.+\/', ''
      $maxShortPathLength = [Math]::Max($maxShortPathLength, $shortPath.Length)
      
      If ($i + 1 -lt $filteredOutput.Length) { $message = $filteredOutput[++$i] }
      Else { $message = 'No message provided' }
    }
    
    If ($fullPath -ne '' -and $shortPath -ne '' -and $message -ne '') {
      $results += [pscustomobject]@{ fullPath = $fullPath; shortPath = $shortPath; message = $message }
    }
  }

  If ($results.Count -eq 0) { Return Write-Success 'No type-check errors found' }

  $options = @()
  $results | ForEach-Object {
    $goToPath = $_.fullPath
    $options += [NavigableMenuElement]@{
      label  = $_.shortPath.PadRight($maxShortPathLength) + '   ' + $_.message
      action = [scriptblock]::Create("code --goto '$goToPath'")
    }
  }
  
  Show-NavigableMenu -menuHeader:'Pnpm Type Check' -options:$options
}
Set-Alias ptc Get-PnpmTypeCheckList
Add-ToFunctionList -category 'Git' -name 'ptc' -value 'Get navigable pnpm type-check list'

function Get-PackageManager {
  Write-Initiate 'Getting package manager for the current project'
  $currentPath = (Get-Location).Path
  $stopPath = $Global:DEFAULT_START_PATH.Path
  $packageJsonFileList = @()

  If ($currentPath -notlike "$stopPath*") { return Write-Fail "The current path is not a subdirectory of the stop path:`n`t'$stopPath'" }
  
  Write-Info 'Searching for package.json files in the current project'
  while ($currentPath -like "$stopPath*") {
    $packageJsonPath = Join-Path -Path $currentPath -ChildPath 'package.json'
    If (Test-Path -Path $packageJsonPath) { $packageJsonFileList += $packageJsonPath }
    
    $parentPath = Split-Path -Path $currentPath -Parent
    If ($parentPath -eq $currentPath) { break }
    $currentPath = $parentPath
  }
  
  If ($packageJsonFileList.Count -eq 0) { return Write-Fail 'No package.json files found in the current project' }
  
  Write-Info 'Checking for package manager in the package.json files'
  foreach ($file in $packageJsonFileList) {
    $jsonContent = Get-Content -Path $file -Raw | ConvertFrom-Json
    If ($jsonContent.packageManager) {
      $packageManager = $jsonContent.packageManager -split '@' | Select-Object -First 1
      Write-Success ('Package manager found: {0}' -f (color_focus $packageManager))
      Return $packageManager
    }
  }
  
  Write-Fail 'No package manager found in any of the package.json files'
}
