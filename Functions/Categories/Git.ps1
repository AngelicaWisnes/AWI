
#########################
# Git-related functions #
#########################

function Test-IsGitRepo { 
  $isGitRepo = git rev-parse --is-inside-work-tree 
  If (-not $isGitRepo) { OUT $(PE -txt:'This is not a git repository' -fg:$global:colors.Red) }
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


function GitCreateNewBranch {
  If (-not (Test-IsGitRepo)) { Return }
  OUT $(PE -txt:"Initiating git checkout -b `n`tName-length  $global:FIFTY_CHARS `n`tBranch-name: ") -NoNewline

  $branchName = Get-ColoredInput

  OUT $(PE -txt:'Trying: git checkout -b '), $(PE -txt:"'$branchName'`n" -fg:$global:colors.DarkCyan)

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
  OUT $(PE -txt:"Initiating git commit -m `n`tMessage-length  $global:FIFTY_CHARS `n`tCommit message: ") -NoNewline

  $commitMessage = Get-ColoredInput

  OUT $(PE -txt:'Trying: git commit -m '), $(PE -txt:"'$commitMessage'`n" -fg:$global:colors.DarkCyan)

  git commit -m $commitMessage
}
Set-Alias cm GitCommitWithMessage
Add-ToFunctionList -category 'Git' -name 'cm' -value 'git commit -m'


function GitCheckout {
  param( [string]$argToCheckout )
  If (-not (Test-IsGitRepo)) { Return }

  If (-not $argToCheckout) {
    OUT $(PE -txt:"No checkout-argument provided. Enter manually:`n`tCheckout-argument: " -fg:$global:colors.Cyan) -NoNewline
    $argToCheckout = Get-ColoredInput
  }

  OUT $(PE -txt:"Initializing following:`n`tgit checkout $argToCheckout" -fg:$global:colors.Cyan)
  git checkout $argToCheckout
}
Set-Alias co GitCheckout
Add-ToFunctionList -category 'Git' -name 'co' -value 'git checkout args'


function GitRebase {
  param( [Parameter(Mandatory)][string]$argToRebase )
  If (-not (Test-IsGitRepo)) { Return }

  If (-not $argToRebase) {
    OUT $(PE -txt:"No rebase-argument provided. Enter manually:`n`Rebase-argument: " -fg:$global:colors.Cyan) -NoNewline
    $argToRebase = Get-ColoredInput
  }

  OUT $(PE -txt:"Initializing following:`n`tgit rebase $argToRebase" -fg:$global:colors.Cyan)
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


function GitCheckoutDevelop { 
  If (-not (Test-IsGitRepo)) { Return }
  git checkout develop 
}
Set-Alias d GitCheckoutDevelop
Add-ToFunctionList -category 'Git' -name 'd' -value 'git checkout develop'


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
  git diff --stat $(git hash-object -t tree /dev/null) 
}
Set-Alias glc Get-TotalLineCountInRepo
Add-ToFunctionList -category 'Git' -name 'glc' -value 'Get total line count in repo'


function GitCombinePreviousCommits {
  If (-not (Test-IsGitRepo)) { Return }
  git log -n 5
  OUT $(PE -txt:"Initiating 'git reset --soft <hash>' to combine all commits done after given hash
  `tPlease provide the commit-hash belonging to the last commit
  `tdone BEFORE the first commit you want to include in this process, according to git log
  `tCommit-Hash: " -fg:$global:colors.Cyan) -NoNewline

  $commitHash = Get-ColoredInput

  OUT $(PE -txt:'Trying: git reset --soft '), $(PE -txt:"'$commitHash'`n" -fg:$global:colors.DarkCyan)

  git reset --soft $commitHash

  OUT $(PE -txt:"Next steps in the process: `n`t- Create the new commit(s) `n`t- Use the command GitPushForce (alias pf)")
}
Set-Alias gcpc GitCombinePreviousCommits
Add-ToFunctionList -category 'Git' -name 'gcpc' -value 'Combine previous commits'


function GitDeleteCurrentBranch {
  If (-not (Test-IsGitRepo)) { Return }
  $currentGitBranch = Get-CurrentGitBranch
  $title = "$(Get-FunctionDefinitionAsString GitCheckoutMaster)  git branch -d $currentGitBranch `n  git push origin --delete $currentGitBranch"
  $question = 'Are you sure you want to proceed?'
  $choices = '&Yes', '&No'

  OUT $(PE -txt:'Trying to run the following commands:') -NoNewline
  $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

  If ($decision -eq 0) {
    OUT $(PE -txt:'Confirmed')
    GitCheckoutMaster
    git branch -d $currentGitBranch
    git push origin --delete $currentGitBranch
  }
  Else { OUT $(PE -txt:'Cancelled') }
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
  OUT $(PE -txt:"Initiating a renaming of current branch. Enter the new branch name `n`tName-length  $global:FIFTY_CHARS `n`tBranch-name: ") -NoNewline

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

  OUT $(PE -txt:'Trying to run the following command:') -NoNewline
  $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

  If ($decision -eq 0) {
    OUT $(PE -txt:'Confirmed')
    git push --set-upstream origin $currentGitBranch
  }
  Else { OUT $(PE -txt:'Cancelled') }
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


function GitHandleBranches {
  OUT $(PE -txt:'Initiating branch handling:' -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[C] Checkout local branch" -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[R] Rebase local branch" -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[D] Delete local branches that have been deleted from remote" -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[N] Create new local branch" -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[S] System dependent branch handling" -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[Any] Cancel" -fg:$global:colors.Yellow),
  $(PE -txt:"`n`nEnter your choice: " -fg:$global:colors.Cyan) -NoNewline

  $userInput = $Host.UI.RawUI.ReadKey().Character
  switch ($userInput.ToString().ToUpper()) {
    'C' { GitChooseLocalBranch }
    'R' { GitRebaseLocalBranch }
    'D' { GitDeleteLocalBranchesDeletedFromRemote }
    'N' { GitCreateNewBranch }
    'S' { Get-SystemDependentGitCheckouts }
    Default { OUT $(PE -txt:"`nCancelling" -fg:$global:colors.Cyan) }
  }
}
Set-Alias b GitHandleBranches
Add-ToFunctionList -category 'Git' -name 'b' -value 'Git handle branches'


function GitChooseLocalBranch {
  OUT $(PE -txt:'Initiating checkout local branch:' -fg:$global:colors.Cyan)

  $localBranchNamesAsList = (git branch --format="%(refname:short)").Split("`n")

  For ($i = 0; $i -lt $localBranchNamesAsList.length; $i++) { OUT $(PE -txt:"`t[$i] $($localBranchNamesAsList[$i])" -fg:$global:colors.Cyan) -NoNewlineStart }
  OUT $(PE -txt:"`t[M] Enter branch name manually" -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[Any] Cancel " -fg:$global:colors.Yellow),
  $(PE -txt:"`n`nEnter your choice: " -fg:$global:colors.Cyan) -NoNewline -NoNewlineStart

  $userInput = $Host.UI.RawUI.ReadKey().Character.ToString()
  OUT
  If ($userInput.ToUpper() -eq 'M') { GitCheckout }
  Elseif (($userInput -match '^\d+$') -and ($userInput -in 0..$($localBranchNamesAsList.Length - 1))) { GitCheckout $localBranchNamesAsList[$userInput] }
  Else { OUT $(PE -txt:"`nCancelling" -fg:$global:colors.Cyan) }
}
Set-Alias cob GitChooseLocalBranch
Add-ToFunctionList -category 'Git' -name 'cob' -value 'Git choose local branch'


function GitRebaseLocalBranch {
  OUT $(PE -txt:'Initiating rebase local branch:' -fg:$global:colors.Cyan)

  $localBranchNamesAsList = (git branch --format="%(refname:short)").Split("`n")

  For ($i = 0; $i -lt $localBranchNamesAsList.length; $i++) { OUT $(PE -txt:"`t[$i] $($localBranchNamesAsList[$i])" -fg:$global:colors.Cyan) -NoNewlineStart }
  OUT $(PE -txt:"`t[M] Enter branch name manually" -fg:$global:colors.Cyan),
  $(PE -txt:"`n`t[Any] Cancel " -fg:$global:colors.Yellow),
  $(PE -txt:"`n`nEnter your choice: " -fg:$global:colors.Cyan) -NoNewline -NoNewlineStart

  $userInput = $Host.UI.RawUI.ReadKey().Character.ToString()
  If ($userInput.ToUpper() -eq 'M') { GitRebase }
  Elseif (($userInput -match '^\d+$') -and ($userInput -in 0..$($localBranchNamesAsList.Length - 1))) { GitRebase $($localBranchNamesAsList[$userInput]) }
  Else { OUT $(PE -txt:"`nCancelling" -fg:$global:colors.Cyan) }
}
Set-Alias rlb GitRebaseLocalBranch
Add-ToFunctionList -category 'Git' -name 'rlb' -value 'Git rebase local branch'


function GitDeleteLocalBranchesDeletedFromRemote {
  If (-not (Test-IsGitRepo)) { Return }
  OUT $(PE -txt:'Initiating deletion of local branches that have been deleted from remote: ' -fg:$global:colors.Cyan)

  git fetch --prune *> $null 2>&1

  OUT $(PE -txt:'These are the remote deleted branches:' -fg:$global:colors.Cyan)
  $branches = git for-each-ref --format '%(refname:short) %(upstream:track)' refs/heads | ForEach-Object {
    $parts = $_ -split ' '
    If ($parts[1] -eq '[gone]') {
      $parts[0]
    }
  }

  If ($branches.length -eq 0) { Return OUT $(PE -txt:"`tNone" -fg:$global:colors.Cyan) -NoNewlineStart }
  $branches | ForEach-Object { OUT $(PE -txt:"`t$_" -fg:$global:colors.Cyan) -NoNewlineStart }

  OUT $(PE -txt:'Continue deleting these branches from local [Y/N (Default)]: ' -fg:$global:colors.Cyan) -NoNewline
  $userInput = $Host.UI.RawUI.ReadKey().Character.ToString()
  If ($userInput.ToUpper() -eq 'Y') {
    OUT
    $branches | ForEach-Object { git branch -D $($_) }
  }
  Else { OUT $(PE -txt:"`nCancelling" -fg:$global:colors.Cyan) }
}
Set-Alias dlb GitDeleteLocalBranchesDeletedFromRemote
Add-ToFunctionList -category 'Git' -name 'dlb' -value 'Git delete local branches deleted from remote'

function Get-CoverageReport {
  If (-not (Test-IsGitRepo)) { Return }
  $jestOutput = pnpm jest --coverage --coverageReporters=text --silent
  
  $coverageHeader = $jestOutput | Select-String -Pattern '^File\s+\|'
  $coverageList = $jestOutput | Select-String -Pattern '^\s*\S+\.\S+\s+\|\s+\d+' | Where-Object { $_ -notmatch '^\*\*' }
  $coverageLineDivider = $jestOutput | Select-String -Pattern '^-{3,}' | Select-Object -First 1

  $firstLineColumnLength = ($coverageList[0].Matches[0].Value).Split('|')[0].Length
  $totalNameLength = $coverageList | ForEach-Object { $_.Matches[0].Value.Split('|')[0].Trim().Length } | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
  $numberOfSpacesToBeRemoved = $firstLineColumnLength - ($totalNameLength + 15)

  $shortenedDivider = "`t|-" + ($coverageLineDivider -replace "-{$numberOfSpacesToBeRemoved}\|", '|') + "|`n"
  $shortenedHeader = "`t| " + ($coverageHeader -replace " {$numberOfSpacesToBeRemoved}\|", '|') + "|`n"
  $shortenedContent = $coverageList | ForEach-Object { $_ -replace " {$numberOfSpacesToBeRemoved}\|", '|' }

  # Print the coverage report in the specified order
  OUT $(PE -txt:($shortenedDivider -replace '-', '¯' ) -fg:$global:colors.Jade), $(PE -txt:$shortenedHeader -fg:$global:colors.Jade), $(PE -txt:$shortenedDivider -fg:$global:colors.Jade) -NoNewline
  $index = 0
  $shortenedContent | ForEach-Object {
    OUT $(PE -txt:"`t| " -fg:$global:colors.Jade) -NoNewline -NoNewlineStart:($index -eq 0)
    $line = $_
    $fullyCovered = ($line -split ' 100 ').Length - 1 -eq 4
    $nameColor = If ($fullyCovered) { $global:colors.Jade } Else { $global:colors.DeepPink }
    $line.Split('|') | ForEach-Object {
      $elementColor = If ($_ -match '100') { $global:colors.Jade } Else { $nameColor }
      OUT $(PE -txt:"$_" -fg:$elementColor), $(PE -txt:'|' -fg:$global:colors.Jade) -NoNewline -NoNewlineStart
    }
    $index++
  }
  OUT $(PE -txt:($shortenedDivider -replace '-', '.' ) -fg:$global:colors.Jade)
}
Set-Alias gcr Get-CoverageReport
Add-ToFunctionList -category 'Git' -name 'gcr' -value 'Get jest coverage report'

function Set-TokenizedRemoteURL {
  If (-not (Test-IsGitRepo)) { Return }
  OUT $(PE -txt:"`tGo to GitHub -> Profile -> Settings -> Developer Settings -> Personal access token, and generate a token. `n`tEnter token: ") -NoNewline
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
