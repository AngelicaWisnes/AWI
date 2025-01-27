# Hardcode the color-sequences to enhance speed for the prompt
$colorYellow = cfg $Global:RGBs.Yellow
$colorDodgerBlue = cfg $Global:RGBs.DodgerBlue
$colorCyan = cfg $Global:RGBs.Cyan
$colorDeepPink = cfg $Global:RGBs.DeepPink
$colorLightSlateBlue = cfg $Global:RGBs.LightSlateBlue
$colorMintGreen = cfg $Global:RGBs.MintGreen
$colorMonaLisa = cfg $Global:RGBs.MonaLisa

$GitPromptPrefix = '{0} [ ' -f $colorYellow
$GitPromptInfix = '{0} | ' -f $colorYellow
$GitPromptPostfix = '{0} ] ' -f $colorYellow
$GitUpstreamPrefix = '{0}(' -f $colorDodgerBlue
$GitUpstreamPostfix = '{0})' -f $colorDodgerBlue

$upArrow = [char]0x2191  # Up arrow
$downArrow = [char]0x2193  # Down arrow
$checkMark = [char]0x2714  # CheckMark
$warning = [char]0x26A0  # Warning sign


function Get-FormattedPath {
  $pathDivider = [System.IO.Path]::DirectorySeparatorChar
  $formattedPath = ($pwd.Path -replace '.*Source', "${pathDivider}Source")
  Return $formattedPath
}


function Get-GitStatusInformation {
  $gitStatusInformation = (git status --porcelain --branch --untracked-files=all 2>$null) -split "`n"
  $statusLength = $gitStatusInformation.Length

  If ($statusLength -gt 0) {
    $branchAndCommitInfo = $gitStatusInformation[0]

    $localBranch = [regex]::Match($branchAndCommitInfo, '(?<=^## )(\S+?)(?=\.\.\.|$| )').Groups[1].Value.Trim()
    $upstreamBranch = [regex]::Match($branchAndCommitInfo, '^## \S+\.\.\.(\S+).*').Groups[1].Value.Trim()
    $upstreamBranch = If ( -not $upstreamBranch ) { '<NoUpstreamSet>' } Else { $upstreamBranch -replace "$localBranch$", '' }

    $commitsToPush = If ($branchAndCommitInfo -match 'ahead (\d+)') { $matches[1] } Else { '0' }
    $commitsToPull = If ($branchAndCommitInfo -match 'behind (\d+)') { $matches[1] } Else { '0' }

    $gitStatusList = $gitStatusInformation[1..($statusLength - 1)]
    $stagedStatus, $unstagedStatus = Get-GitStatusCounters -gitStatusList $gitStatusList

    Return @($upstreamBranch, $localBranch, $commitsToPull, $commitsToPush, $stagedStatus, $unstagedStatus)
  }

  Return $null
}


function Get-GitStatusCounters {
  param ( [string[]]$gitStatusList )

  $stagedStatus = @{'+' = 0; '~' = 0; '-' = 0 }
  $unstagedStatus = @{'+' = 0; '~' = 0; '-' = 0 }

  foreach ($line in $gitStatusList) {
    If ($line.Length -ge 2) {
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
  [void]$sb.Append($GitUpstreamPrefix + $colorCyan + $upstreamBranch)
  [void]$sb.Append($GitUpstreamPostfix + $colorCyan + $localBranch)

  # GitPrompt Pull information
  If ( $commitsToPull -gt 0 ) {
    [void]$sb.Append($GitPromptInfix + $colorDeepPink + $downArrow + ' ' + $commitsToPull)
  }

  # GitPrompt Push information
  If ( $commitsToPush -gt 0 ) {
    [void]$sb.Append($GitPromptInfix + $colorLightSlateBlue + $upArrow + ' ' + $commitsToPush)
  }

  # GitPrompt Staged information
  $stagedAdded = $stagedStatus['+']
  $stagedChanged = $stagedStatus['~']
  $stagedDeleted = $stagedStatus['-']
  If ( ($stagedAdded -gt 0) -or ($stagedChanged -gt 0) -or ($stagedDeleted -gt 0) ) {
    [void]$sb.Append($GitPromptInfix + $colorMintGreen + $checkMark + '  +' + $stagedAdded + ' ~' + $stagedChanged + ' -' + $stagedDeleted)
  }

  # GitPrompt Unstaged information
  $unstagedAdded = $unstagedStatus['+']
  $unstagedChanged = $unstagedStatus['~']
  $unstagedDeleted = $unstagedStatus['-']
  If ( ($unstagedAdded -gt 0) -or ($unstagedChanged -gt 0) -or ($unstagedDeleted -gt 0) ) {
    [void]$sb.Append($GitPromptInfix + $colorMonaLisa + $warning + '  +' + $unstagedAdded + ' ~' + $unstagedChanged + ' -' + $unstagedDeleted)
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
  [void]$sb.Append('{0}> ' -f (cr))

  $sb.ToString()
}
