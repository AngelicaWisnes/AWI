# Hardcode the color-sequences to enhance speed for the prompt
$colorYellow = "$global:COLOR_ESCAPE[38;2;{0};{1};{2}m" -f $colors.Yellow.rgb.r, $colors.Yellow.rgb.g, $colors.Yellow.rgb.b
$colorDodgerBlue = "$global:COLOR_ESCAPE[38;2;{0};{1};{2}m" -f $colors.DodgerBlue.rgb.r, $colors.DodgerBlue.rgb.g, $colors.DodgerBlue.rgb.b
$colorCyan = "$global:COLOR_ESCAPE[38;2;{0};{1};{2}m" -f $colors.Cyan.rgb.r, $colors.Cyan.rgb.g, $colors.Cyan.rgb.b
$colorDeepPink = "$global:COLOR_ESCAPE[38;2;{0};{1};{2}m" -f $colors.DeepPink.rgb.r, $colors.DeepPink.rgb.g, $colors.DeepPink.rgb.b
$colorLightSlateBlue = "$global:COLOR_ESCAPE[38;2;{0};{1};{2}m" -f $colors.LightSlateBlue.rgb.r, $colors.LightSlateBlue.rgb.g, $colors.LightSlateBlue.rgb.b
$colorMintGreen = "$global:COLOR_ESCAPE[38;2;{0};{1};{2}m" -f $colors.MintGreen.rgb.r, $colors.MintGreen.rgb.g, $colors.MintGreen.rgb.b
$colorMonaLisa = "$global:COLOR_ESCAPE[38;2;{0};{1};{2}m" -f $colors.MonaLisa.rgb.r, $colors.MonaLisa.rgb.g, $colors.MonaLisa.rgb.b

$GitPromptPrefix = "{0} [ {1}" -f $colorYellow, $global:RESET_SEQUENCE
$GitPromptInfix = "{0} | {1}" -f $colorYellow, $global:RESET_SEQUENCE
$GitPromptPostfix = "{0} ] {1}" -f $colorYellow, $global:RESET_SEQUENCE
$GitUpstreamPrefix = "{0}({1}" -f $colorDodgerBlue, $global:RESET_SEQUENCE
$GitUpstreamPostfix = "{0}){1}" -f $colorDodgerBlue, $global:RESET_SEQUENCE

function Get-FormattedPath { 
  $pathDivider = [System.IO.Path]::DirectorySeparatorChar
  $formattedPath = ($pwd.Path -replace '.*Source', "${pathDivider}Source") 
  Return $formattedPath
}

function Get-GitUncommittedFileCount {
  param (
    [Parameter(Mandatory)][string]$gitStatus,
    [Parameter(Mandatory)][string]$statusCode,
    [Parameter(Mandatory)][int]$searchIndex
  )
  Return ($gitStatus | Where-Object { $_[$searchIndex] -eq $statusCode }).Count
}

function Get-GitStatusCounters {
  $statusList = @(
    @{ 'A' = 0; 'M' = 0; 'D' = 0 } # For staged changes
    @{ '?' = 0; 'M' = 0; 'D' = 0 } # For unstaged changes
  )
  
  $gitStatus = git status --porcelain
  
  foreach ($line in $gitStatus -split "`n") {
    if ($line.Length -ge 2) {
      $stagedStatusCode = [string]$line[0]
      $unstagedStatusCode = [string]$line[1]
      
      if ($statusList[0].ContainsKey($stagedStatusCode)) { $statusList[0][$stagedStatusCode]++ }
      if ($statusList[1].ContainsKey($unstagedStatusCode)) { $statusList[1][$unstagedStatusCode]++ } 
    }
  }
  
  return $statusList
}


function Get-GitPrompt {
  $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
  If (-not $isGitRepo) { Return }
  
  $sb = [System.Text.StringBuilder]::new()
  
  $upArrow = [char]0x2191  # Up arrow
  $downArrow = [char]0x2193  # Down arrow
  $checkmark = [char]0x2714  # Checkmark
  $warning = [char]0x26A0  # Warning sign
  
  $statusList = Get-GitStatusCounters -gitStatus $gitStatus
  
  # GitPrompt Prefix
  [void]$sb.Append($GitPromptPrefix)
  #Get-GitPromptPrefix
  
  # Git branch information
  $localBranch = git rev-parse --abbrev-ref HEAD 2>$null
  $upstreamBranch = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
  $upstreamBranch = if ( -not $upstreamBranch ) { "<NoUpstreamSet>" } else { $upstreamBranch -replace "$localBranch$", '' }
  [void]$sb.Append($GitUpstreamPrefix + $colorCyan + $upstreamBranch + $global:RESET_SEQUENCE)
  [void]$sb.Append($GitUpstreamPostfix + $colorCyan + $localBranch + $global:RESET_SEQUENCE)
  
  # GitPrompt Pull information
  $commitsToPull = (git cherry -v HEAD '@{u}').count 2>$null
  If ( $commitsToPull -gt 0 ) { 
    [void]$sb.Append($GitPromptInfix + $colorDeepPink + $downArrow + " " + $commitsToPull + $global:RESET_SEQUENCE)
  }
    
  # GitPrompt Push information
  $commitsToPush = (git cherry -v '@{u}').count 2>$null
  If ( $commitsToPush -gt 0 ) { 
    [void]$sb.Append($GitPromptInfix + $colorLightSlateBlue + $upArrow + " " + $commitsToPush + $global:RESET_SEQUENCE)
  }
      
  # GitPrompt Staged information
  $stagedAdded = $statusList[0]['A']
  $stagedChanged = $statusList[0]['M']
  $stagedDeleted = $statusList[0]['D']
  If ( ($stagedAdded -gt 0) -or ($stagedChanged -gt 0) -or ($stagedDeleted -gt 0) ) { 
    [void]$sb.Append($GitPromptInfix + $colorMintGreen + $checkmark + " +" + $stagedAdded + " ~" + $stagedChanged + " -" + $stagedDeleted + $global:RESET_SEQUENCE)
  }
        
  # GitPrompt Unstaged information
  $unstagedAdded = $statusList[1]['?']
  $unstagedChanged = $statusList[1]['M']
  $unstagedDeleted = $statusList[1]['D']
  If ( ($unstagedAdded -gt 0) -or ($unstagedChanged -gt 0) -or ($unstagedDeleted -gt 0) ) { 
    [void]$sb.Append($GitPromptInfix + $colorMonaLisa + $warning + " +" + $unstagedAdded + " ~" + $unstagedChanged + " -" + $unstagedDeleted + $global:RESET_SEQUENCE)
  }
          
  # GitPrompt Postfix
  [void]$sb.Append($GitPromptPostfix)
  Return $sb.ToString()
}


function Prompt {
  $sb = [System.Text.StringBuilder]::new()

  # Prefix
  [void]$sb.Append("`n")

  # Formatted path
  [void]$sb.Append($(Get-FormattedPath))

  # Git information
  [void]$sb.Append($(Get-GitPrompt))

  # Postfix
  [void]$sb.Append("> ")

  $sb.ToString()
}