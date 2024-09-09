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

$upArrow = [char]0x2191  # Up arrow
$downArrow = [char]0x2193  # Down arrow
$checkmark = [char]0x2714  # Checkmark
$warning = [char]0x26A0  # Warning sign


function Get-FormattedPath { 
  $pathDivider = [System.IO.Path]::DirectorySeparatorChar
  $formattedPath = ($pwd.Path -replace '.*Source', "${pathDivider}Source") 
  Return $formattedPath
}


function Get-GitStatusInformation {
  $gitStatusInformation = (git status --porcelain --branch --untracked-files=all 2>$null) -split "`n"
  $statusLength = $gitStatusInformation.Length

  if ($statusLength -gt 0) {
    $branchAndCommitInfo = $gitStatusInformation[0]
    
    $localBranch = ($branchAndCommitInfo -replace '^## (\S+)\.\.\..*', '$1').Trim()
    $upstreamBranch = ($branchAndCommitInfo -replace '^## \S+\.\.\.(\S+).*', '$1').Trim()
    
    $commitsToPush = if ($branchAndCommitInfo -match 'ahead (\d+)') { $matches[1] } else { "0" }
    $commitsToPull = if ($branchAndCommitInfo -match 'behind (\d+)') { $matches[1] } else { "0" }
    
    $gitStatusList = $gitStatusInformation[1..($statusLength - 1)]
    $stagedStatus, $unstagedStatus = Get-GitStatusCounters -gitStatusList $gitStatusList

    Return @($upstreamBranch, $localBranch, $commitsToPull, $commitsToPush, $stagedStatus, $unstagedStatus)
  }

  Return $null
}


function Get-GitStatusCounters {
  param ( [string[]]$gitStatusList )

  $stagedStatus = @{'+'=0; '~'=0; '-'=0}
  $unstagedStatus = @{'+'=0; '~'=0; '-'=0}
  
  foreach ($line in $gitStatusList) {
    if ($line.Length -ge 2) {
      $stagedStatusCode = [string]$line[0]
      $unstagedStatusCode = [string]$line[1]

      switch ($stagedStatusCode) {
        'A' { $stagedStatus['+']++ }
        'M' { $stagedStatus['~']++ }
        'T' { $stagedStatus['~']++ }
        'R' { $stagedStatus['~']++ }
        'C' { $stagedStatus['~']++ }
        'D' { $stagedStatus['-']++ }
      }
      
      switch ($unstagedStatusCode) {
        '?' { $unstagedStatus['+']++ }
        'M' { $unstagedStatus['~']++ }
        'T' { $unstagedStatus['~']++ }
        'R' { $unstagedStatus['~']++ }
        'C' { $unstagedStatus['~']++ }
        'D' { $unstagedStatus['-']++ }
      }
    }
  }

  Return @($stagedStatus, $unstagedStatus)
}


function Get-GitPrompt {
  $gitStatusInformation = Get-GitStatusInformation
  If (-not $gitStatusInformation) { Return }

  $upstreamBranch, $localBranch, $commitsToPull, $commitsToPush, $stagedStatus, $unstagedStatus = $gitStatusInformation

  $sb = [System.Text.StringBuilder]::new()  
  
  # GitPrompt Prefix
  [void]$sb.Append($GitPromptPrefix)
  #Get-GitPromptPrefix
  
  # Git branch information
  $upstreamBranch = if ( -not $upstreamBranch ) { "<NoUpstreamSet>" } else { $upstreamBranch -replace "$localBranch$", '' }
  [void]$sb.Append($GitUpstreamPrefix + $colorCyan + $upstreamBranch + $global:RESET_SEQUENCE)
  [void]$sb.Append($GitUpstreamPostfix + $colorCyan + $localBranch + $global:RESET_SEQUENCE)
  
  # GitPrompt Pull information
  If ( $commitsToPull -gt 0 ) { 
    [void]$sb.Append($GitPromptInfix + $colorDeepPink + $downArrow + " " + $commitsToPull + $global:RESET_SEQUENCE)
  }
    
  # GitPrompt Push information
  If ( $commitsToPush -gt 0 ) { 
    [void]$sb.Append($GitPromptInfix + $colorLightSlateBlue + $upArrow + " " + $commitsToPush + $global:RESET_SEQUENCE)
  }
      
  # GitPrompt Staged information
  $stagedAdded = $stagedStatus['+']
  $stagedChanged = $stagedStatus['~']
  $stagedDeleted = $stagedStatus['-']
  If ( ($stagedAdded -gt 0) -or ($stagedChanged -gt 0) -or ($stagedDeleted -gt 0) ) { 
    [void]$sb.Append($GitPromptInfix + $colorMintGreen + $checkmark + " +" + $stagedAdded + " ~" + $stagedChanged + " -" + $stagedDeleted + $global:RESET_SEQUENCE)
  }
        
  # GitPrompt Unstaged information
  $unstagedAdded = $unstagedStatus['+']
  $unstagedChanged = $unstagedStatus['~']
  $unstagedDeleted = $unstagedStatus['-']
  If ( ($unstagedAdded -gt 0) -or ($unstagedChanged -gt 0) -or ($unstagedDeleted -gt 0) ) { 
    [void]$sb.Append($GitPromptInfix + $colorMonaLisa + $warning + " +" + $unstagedAdded + " ~" + $unstagedChanged + " -" + $unstagedDeleted + $global:RESET_SEQUENCE)
  }
          
  # GitPrompt Postfix
  [void]$sb.Append($GitPromptPostfix)
  Return $sb.ToString()
}


function prompt {
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
