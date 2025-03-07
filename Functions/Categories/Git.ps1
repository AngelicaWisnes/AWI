
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


function GitAddAllOrArg {
  If (-not (Test-IsGitRepo)) { Return }
  If ($args.Length -eq 0) { git add . }
  Else { git add $args }
  Get-GitStatusStandard
}
Set-Alias a GitAddAllOrArg
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


function GitCreateNewBranch {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Initiate 'New branch creation'
  $branchType = Get-GitBranchType
  $branchPrefix = Get-GitBranchPrefix
  $branchNamePrefix = '{0}{1}' -f $branchType, $branchPrefix
  
  Write-Prompt "Preparing 'git checkout -b'. Please enter branch-name" -NoNewline
  Write-Info "`tName-length  $global:FIFTY_CHARS `n`tBranch-name: $branchNamePrefix" -NoNewline
  $branchInput = Get-ColoredInput
  $branchName = $branchNamePrefix + $branchInput

  Write-Info ("Trying: {0}git checkout -b '{1}'`n" -f $Global:RGBs.DarkCyan.fg, $branchName)

  git checkout -b $branchName
}
Set-Alias gcb GitCreateNewBranch
Add-ToFunctionList -category 'Git' -name 'gcb' -value 'git checkout -b'


function GitCommit { 
  If (-not (Test-IsGitRepo)) { Return }
  git commit 
}
Set-Alias c GitCommit
Add-ToFunctionList -category 'Git' -name 'c' -value 'git commit'


function GitCommitWithMessage {
  If (-not (Test-IsGitRepo)) { Return }
  Write-Prompt "Preparing 'git commit -m'. Please enter commit-message" -NoNewline
  Write-Info "`tMessage-length  $global:FIFTY_CHARS `n`tCommit message: " -NoNewline

  $commitMessage = Get-ColoredInput
  Write-Info ("Trying: {0}git commit -m '{1}'`n" -f $Global:RGBs.DarkCyan.fg, $commitMessage)

  git commit -m $commitMessage
}
Set-Alias cm GitCommitWithMessage
Add-ToFunctionList -category 'Git' -name 'cm' -value 'git commit -m'


function GitCheckout {
  param( [string]$argToCheckout )
  If (-not (Test-IsGitRepo)) { Return }

  If (-not $argToCheckout) {
    Write-Info "No checkout-argument provided. Enter manually:`n`tCheckout-argument: " -NoNewline
    $argToCheckout = Get-ColoredInput
  }

  Write-Info ("Initializing following:`n`t{0}git checkout {1}" -f $Global:RGBs.DarkCyan.fg, $argToCheckout)
  git checkout $argToCheckout
}
Set-Alias co GitCheckout
Add-ToFunctionList -category 'Git' -name 'co' -value 'git checkout args'


function GitRebase {
  param( [Parameter(Mandatory)][string]$argToRebase )
  If (-not (Test-IsGitRepo)) { Return }

  If (-not $argToRebase) {
    Write-Info "No rebase-argument provided. Enter manually:`n`Rebase-argument: " -NoNewline
    $argToRebase = Get-ColoredInput
  }

  Write-Info ("Initializing following:`n`t{0}git rebase {1}" -f $Global:RGBs.DarkCyan.fg, $argToRebase)
  git rebase $argToRebase
}
Set-Alias gra GitRebase
Add-ToFunctionList -category 'Git' -name 'gra' -value 'git rebase args'


function GitCheckoutPrevious { 
  If (-not (Test-IsGitRepo)) { Return }
  git checkout - 
}
Set-Alias co- GitCheckoutPrevious
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


function GitCombinePreviousCommits {
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

  Write-Info "Next steps in the process: `n`t- Create the new commit(s) `n`t- Use the command GitPushForce (alias pf)"
}
Set-Alias gcpc GitCombinePreviousCommits
Add-ToFunctionList -category 'Git' -name 'gcpc' -value 'Combine previous commits'


function GitDeleteCurrentBranch {
  If (-not (Test-IsGitRepo)) { Return }
  $currentGitBranch = Get-CurrentGitBranch
  $masterBranch = Get-MasterBranch
  If ($currentGitBranch -eq $masterBranch) { Return Write-Fail 'Cannot delete master branch' }

  $title = "$(Get-FunctionDefinitionAsString GitCheckoutMaster)  git branch -d $currentGitBranch `n  git push origin --delete $currentGitBranch"
  $question = 'Are you sure you want to proceed?'
  $choices = '&Yes', '&No'

  Write-Info 'Trying to run the following commands:' -NoNewline
  $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

  If ($decision -eq 0) {
    Write-Info 'Confirmed'
    GitCheckoutMaster
    git branch -d $currentGitBranch
    git push origin --delete $currentGitBranch
  }
  Else { Write-Info 'Cancelled' }
}
Set-Alias gd GitDeleteCurrentBranch
Add-ToFunctionList -category 'Git' -name 'gd' -value 'Delete current branch (local&remote)'


function GitMergeCurrentIntoMaster {
  If (-not (Test-IsGitRepo)) { Return }
  $currentBranch = Get-CurrentGitBranch
  GitCheckoutMaster
  git merge $currentBranch
}
Set-Alias gmc GitMergeCurrentIntoMaster
Add-ToFunctionList -category 'Git' -name 'gmc' -value 'git merge current into master'


function GitMergeArgs { 
  If (-not (Test-IsGitRepo)) { Return }
  git merge $args 
}
Set-Alias gma GitMergeArgs
Add-ToFunctionList -category 'Git' -name 'gme' -value 'git merge args'


function GitMergeMaster {
  If (-not (Test-IsGitRepo)) { Return }
  $masterBranch = Get-MasterBranch
  git merge $masterBranch
}
Set-Alias gmm GitMergeMaster
Add-ToFunctionList -category 'Git' -name 'gmm' -value 'git merge master'


function GitPull { 
  If (-not (Test-IsGitRepo)) { Return }
  git pull 
}
Set-Alias gpl GitPull
Add-ToFunctionList -category 'Git' -name 'gpl' -value 'git pull'


function GitPruneAndPull {
  If (-not (Test-IsGitRepo)) { Return }
  GitPrune
  GitPull
}
Set-Alias gppl GitPruneAndPull
Add-ToFunctionList -category 'Git' -name 'gppl' -value 'git gc --prune=now && git pull'


function GitHardReset { 
  If (-not (Test-IsGitRepo)) { Return }
  git reset --hard 
}
Set-Alias gr GitHardReset
Add-ToFunctionList -category 'Git' -name 'gr' -value 'git reset --hard'


function GitRenameBranch {
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
Set-Alias grb GitRenameBranch
Add-ToFunctionList -category 'Git' -name 'grb' -value 'Rename git branch'


function GitCheckoutMaster {
  If (-not (Test-IsGitRepo)) { Return }
  $masterBranch = Get-MasterBranch
  git checkout $masterBranch
}
Set-Alias m GitCheckoutMaster
Add-ToFunctionList -category 'Git' -name 'm' -value 'git checkout master/main'


function GitOpenBranchInBrowser {
  param(
    [string]$repo = $(Get-CurrentRepo),
    [string]$currentGitBranch = $(Get-CurrentGitBranch)
  )
  If (-not (Test-IsGitRepo)) { Return }
  Start-Process $global:MY_BROWSER -ArgumentList $(Get-GitBranchUrl -repo $repo -branch $currentGitBranch)
}
Set-Alias ob GitOpenBranchInBrowser
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


function GitPush { 
  If (-not (Test-IsGitRepo)) { Return }
  git push 
}
Set-Alias p GitPush
Add-ToFunctionList -category 'Git' -name 'p' -value 'git push'


function GitPushForce { 
  If (-not (Test-IsGitRepo)) { Return }
  git push --force-with-lease 
}
Set-Alias pf GitPushForce
Add-ToFunctionList -category 'Git' -name 'pf' -value 'git push --force-with-lease'


function GitPushAndOpenBranchInBrowser {
  If (-not (Test-IsGitRepo)) { Return }
  GitPush
  GitOpenBranchInBrowser
}
Set-Alias po GitPushAndOpenBranchInBrowser
Add-ToFunctionList -category 'Git' -name 'po' -value 'git push && Open git-branch i browser'


function GitSetUpstreamAndPush {
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
Set-Alias pu GitSetUpstreamAndPush
Add-ToFunctionList -category 'Git' -name 'pu' -value 'git push --set-upstream origin'


function GitPrune { 
  If (-not (Test-IsGitRepo)) { Return }
  git gc --prune=now 
}
Set-Alias gpr GitPrune
Add-ToFunctionList -category 'Git' -name 'gpr' -value 'git gc --prune=now'


function GitQuickCommitAll {
  If (-not (Test-IsGitRepo)) { Return }
  git add .
  git commit -m 'Various small changes'
}
Set-Alias qca GitQuickCommitAll
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
    [NavigableMenuElement]@{trigger = 'C'; label = 'Checkout local branch'; action = { GitChooseLocalBranch } },
    [NavigableMenuElement]@{trigger = 'R'; label = 'Rebase local branch'; action = { GitRebaseLocalBranch } },
    [NavigableMenuElement]@{trigger = 'D'; label = 'Delete local branches that have been deleted from remote'; action = { GitDeleteLocalBranchesDeletedFromRemote } },
    [NavigableMenuElement]@{trigger = 'N'; label = 'Create new local branch'; action = { GitCreateNewBranch } },
    [NavigableMenuElement]@{trigger = 'S'; label = 'System dependent branch handling'; action = { Get-SystemDependentGitCheckouts } }
  )
  Show-NavigableMenu -menuHeader:'Branch handling' -options:$options
}
Set-Alias b Invoke-GitBranchHandler
Add-ToFunctionList -category 'Git' -name 'b' -value 'Git handle branches'


function GitChooseLocalBranch {
  If (-not (Test-IsGitRepo)) { Return }

  $localBranchNamesAsList = (git branch --format="%(refname:short)").Split("`n")
  $numberOfBranches = $localBranchNamesAsList.Length
  If ($numberOfBranches -eq 0) { Return Write-Fail 'No local branches found' }

  $options = @()
  $localBranchNamesAsList | ForEach-Object {
    $trigger = If ($localBranchNamesAsList.IndexOf($_) -lt 10) { $localBranchNamesAsList.IndexOf($_).ToString() } Else { $null }
    $options += [NavigableMenuElement]@{ trigger = $trigger; label = $_; action = [scriptblock]::Create("GitCheckout '$_'") }
  }
  $options += [NavigableMenuElement]@{ trigger = 'M'; label = 'Enter branch name manually'; action = { GitCheckout } }
  
  Show-NavigableMenu -menuHeader:'Checkout local branch' -options:$options
}
Set-Alias cob GitChooseLocalBranch
Add-ToFunctionList -category 'Git' -name 'cob' -value 'Git choose local branch'


function GitRebaseLocalBranch {
  If (-not (Test-IsGitRepo)) { Return }

  $localBranchNamesAsList = (git branch --format="%(refname:short)").Split("`n")
  $numberOfBranches = $localBranchNamesAsList.Length
  If ($numberOfBranches -eq 0) { Return Write-Fail 'No local branches found' }

  $options = @()
  $localBranchNamesAsList | ForEach-Object {
    $trigger = If ($localBranchNamesAsList.IndexOf($_) -lt 10) { $localBranchNamesAsList.IndexOf($_).ToString() } Else { $null }
    $options += [NavigableMenuElement]@{ trigger = $trigger; label = $_; action = [scriptblock]::Create("GitRebase '$_'") }
  }
  $options += [NavigableMenuElement]@{ trigger = 'M'; label = 'Enter branch name manually'; action = { GitRebase } }
  
  Show-NavigableMenu -menuHeader:'Rebase local branch' -options:$options
}
Set-Alias rlb GitRebaseLocalBranch
Add-ToFunctionList -category 'Git' -name 'rlb' -value 'Git rebase local branch'


function GitDeleteLocalBranchesDeletedFromRemote {
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
  Else { Write-Info 'Cancelling...' }
}
Set-Alias dlb GitDeleteLocalBranchesDeletedFromRemote
Add-ToFunctionList -category 'Git' -name 'dlb' -value 'Git delete local branches deleted from remote'

function Get-CoverageReport {
  param([string]$focus)
  If (-not (Test-IsGitRepo)) { Return }
  $jestOutput = pnpm jest --coverage --coverageReporters=text --silent
  
  $coverageHeader = $jestOutput | Select-String -Pattern '^File\s+\|'
  $coverageLineDivider = $jestOutput | Select-String -Pattern '^-{3,}' | Select-Object -First 1
  $coverageList = $jestOutput | Select-String -Pattern '(^All files\s+\||^\s*\S+\.\S+\s+\|\s+\d+)' | Where-Object { $_ -notmatch '^\*\*' }

  $firstLineColumnLength = ($coverageList[0].Matches[0].Value).Split('|')[0].Length
  $totalNameLength = $coverageList | ForEach-Object { $_.Matches[0].Value.Split('|')[0].Trim().Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
  $numberOfSpacesToBeRemoved = $firstLineColumnLength - ($totalNameLength + 5)

  $shortenedDivider = "`t|-" + ($coverageLineDivider -replace "-{$numberOfSpacesToBeRemoved}\|", '|') + '|'
  $shortenedHeader = "`t| " + ($coverageHeader -replace " {$numberOfSpacesToBeRemoved}\|", '|') + '|'
  $shortenedContent = $coverageList | ForEach-Object { $_ -replace " {$numberOfSpacesToBeRemoved}\|", '|' }
  
  $frame = ('{0}|' -f $Global:RGBs.Jade.fg)
  $GetElementColor = { param([string]$element) 
    If ($element -match '100') { Return  $Global:RGBs.Jade }
    Elseif ($focus -and $element -match $focus) { Return  $Global:RGBs.Yellow }
    Else { Return  $Global:RGBs.DeepPink }
  }

  # Print the coverage report in the specified order
  $sb = [System.Text.StringBuilder]::new()
  [void]$sb.Append(("`n{0}{1}`n{0}{2}`n{0}{3}" -f $Global:RGBs.Jade.fg, ($shortenedDivider -replace '-', '¯'), $shortenedHeader, $shortenedDivider))
  Foreach ( $line in $shortenedContent ) {
    $fullyCovered = ($line -split ' 100 ').Length - 1 -eq 4
    
    [void]$sb.Append(("`n`t$frame "))
    If ( $fullyCovered) { [void]$sb.Append(('{0}{1}{2}' -f $Global:RGBs.Jade.fg, $line, $frame)) }
    Elseif ($line -match 'All files') { 
      $line.Split('|') | ForEach-Object { [void]$sb.Append(('{0}{1}{2}' -f $Global:RGBs.LightSlateBlue.fg, $_, $frame)) } 
      [void]$sb.Append(("`n{0}{1}" -f $Global:RGBs.Jade.fg, $shortenedDivider))
    }
    Else {
      $elements = $line.Split('|')
      for ($i = 0; $i -lt $elements.Length; $i++) {
        $color = If ($i -eq $elements.Length - 1) { $Global:RGBs.DeepPink } Else { $GetElementColor.Invoke($elements[$i]) }
        [void]$sb.Append(('{0}{1}{2}' -f $color.fg, $elements[$i], $frame))
      } 
    }
  }
  [void]$sb.Append(("`n{0}{1}{2}" -f $Global:RGBs.Jade.fg, ($shortenedDivider -replace '-', '.' ), $Global:RGB_RESET))

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
