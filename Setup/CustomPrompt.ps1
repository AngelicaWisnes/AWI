
function Get-FormattedPath { 
  $pathDivider = [System.IO.Path]::DirectorySeparatorChar
  $formattedPath = ($pwd.Path -replace '.*Source', "${pathDivider}Source") 
  OUT $(PE -txt:"$formattedPath") -NoNewlineStart -NoNewline
}

function Get-GitUncommittedFileCount {
  param (
    [Parameter(Mandatory)][string]$statusCode,
    [Parameter(Mandatory)][int]$searchIndex
  )
  Return (git status --porcelain | Where-Object { $_[$searchIndex] -eq $statusCode }).Count
}

function Get-GitPrompt {
  $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
  If (-not $isGitRepo) { Return }

  $upArrow = [char]0x2191  # Up arrow
  $downArrow = [char]0x2193  # Down arrow
  $checkmark = [char]0x2714  # Checkmark
  $warning = [char]0x26A0  # Warning sign

  function Get-GitPromptInfix { OUT $(PE -txt:" | " -fg:$colors.Yellow) -NoNewlineStart -NoNewline }
  
  # GitPrompt Prefix
  OUT $(PE -txt:" [ " -fg:$colors.Yellow) -NoNewlineStart -NoNewline

  # Git branch information
  $localBranch = git rev-parse --abbrev-ref HEAD 2>$null
  $upstreamBranch = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
  $upstreamBranch = if ( -not $upstreamBranch ) { "<NoUpstreamSet>" } else { $upstreamBranch -replace "$localBranch$", '' }
  OUT $(PE -txt:"(" -fg:$colors.DodgerBlue), $(PE -txt:"$upstreamBranch" -fg:$colors.cyan), 
      $(PE -txt:")" -fg:$colors.DodgerBlue), $(PE -txt:"$localBranch" -fg:$colors.Cyan) -NoNewlineStart -NoNewline

  # GitPrompt Pull information
  $commitsToPull = (git cherry -v HEAD '@{u}').count 2>$null
  If ( $commitsToPull -gt 0 ) { 
    Get-GitPromptInfix
    OUT $(PE -txt:"$downArrow $commitsToPull" -fg:$colors.DeepPink) -NoNewlineStart -NoNewline
  }

    
  # GitPrompt Push information
  $commitsToPush = (git cherry -v '@{u}').count 2>$null
  If ( $commitsToPush -gt 0 ) { 
    Get-GitPromptInfix
    OUT $(PE -txt:"$upArrow $commitsToPush" -fg:$colors.LightSlateBlue) -NoNewlineStart -NoNewline
  }
  
  # GitPrompt Staged information
  $stagedAdded = Get-GitUncommittedFileCount -statusCode "A" -searchIndex 0
  $stagedChanged = Get-GitUncommittedFileCount -statusCode "M" -searchIndex 0
  $stagedDeleted = Get-GitUncommittedFileCount -statusCode "D" -searchIndex 0
  If ( ($stagedAdded -gt 0) -or ($stagedChanged -gt 0) -or ($stagedDeleted -gt 0) ) { 
    Get-GitPromptInfix
    OUT $(PE -txt:"$checkmark +$stagedAdded ~$stagedChanged -$stagedDeleted" -fg:$colors.MintGreen) -NoNewlineStart -NoNewline
  }
  
  # GitPrompt Unstaged information
  $unstagedAdded = Get-GitUncommittedFileCount -statusCode "?" -searchIndex 1
  $unstagedChanged = Get-GitUncommittedFileCount -statusCode "M" -searchIndex 1
  $unstagedDeleted = Get-GitUncommittedFileCount -statusCode "D" -searchIndex 1
  If ( ($unstagedAdded -gt 0) -or ($unstagedChanged -gt 0) -or ($unstagedDeleted -gt 0) ) { 
    Get-GitPromptInfix
    OUT $(PE -txt:"$warning +$unstagedAdded ~$unstagedChanged -$unstagedDeleted" -fg:$colors.MonaLisa) -NoNewlineStart -NoNewline
  }

  # GitPrompt Postfix
  OUT $(PE -txt:" ] " -fg:$colors.Yellow) -NoNewlineStart -NoNewline
}


function Prompt {
  # Prefix
  OUT $(PE -txt:"`n") -NoNewlineStart -NoNewline

  # Formatted path
  Get-FormattedPath

  # Git information
  Get-GitPrompt

  # Postfix
  "> "
}