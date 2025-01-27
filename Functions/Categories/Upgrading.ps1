
function UpgradeWinget {
  winget upgrade --all
}
Set-Alias uw UpgradeWinget
Add-ToFunctionList -category 'Upgrading' -name 'uw' -value 'Upgrade winget'

function UpgradeChoco {
  choco upgrade all
  # choco upgrade all --except="'skype,conemu'"
}
Set-Alias uc UpgradeChoco
Add-ToFunctionList -category 'Upgrading' -name 'uc' -value 'Upgrade choco'




function Get-WingetUpgradeList {
  class Software {
    [string]$Name
    [string]$Id
    [string]$Version
    [string]$AvailableVersion
  }

  $lines = (winget upgrade | Out-String).Split([Environment]::NewLine)

  # Find the line that starts with Name, it contains the header
  $fl = 0
  while (-not $lines[$fl].StartsWith('Name')) { $fl++ }

  # Line $fl has the header, we can find char where we find ID and Version
  $idStart = $lines[$fl].IndexOf('Id')
  $versionStart = $lines[$fl].IndexOf('Version')
  $availableStart = $lines[$fl].IndexOf('Available')
  $sourceStart = $lines[$fl].IndexOf('Source')

  # Now cycle in real package and split accordingly
  $upgradeList_winget = @()
  For ($i = $fl + 1; $i -le $lines.Length; $i++) {
    $line = $lines[$i]
    If ($line.Length -gt ($availableStart + 1) -and -not $line.StartsWith('-')) {
      $name = $line.Substring(0, $idStart).TrimEnd()
      $id = $line.Substring($idStart, $versionStart - $idStart).TrimEnd()
      $version = $line.Substring($versionStart, $availableStart - $versionStart).TrimEnd()
      $available = $line.Substring($availableStart, $sourceStart - $availableStart).TrimEnd()

      $upgradeList_winget += [Software]@{
        Name             = $name
        Id               = $id
        Version          = $version
        AvailableVersion = $available
      }
    }
  }

  Return $upgradeList_winget | Format-Table
}

function Get-ChocoUpgradeLists {
  Return choco outdated -r | ConvertFrom-Csv -Delimiter '|' -Header 'Name', 'Version', 'AvailableVersion', 'Pinned?' | Format-Table
}


function Get-UpgradeLists {
  Get-WingetUpgradeList
  Get-ChocoUpgradeLists
}
Set-Alias u Get-UpgradeLists
Add-ToFunctionList -category 'Upgrading' -name 'u' -value 'Get upgrade lists'


function Get-UpgradeListsInfo {
  Write-Host "Enter 'u' to list all available 'winget'- and 'choco'-upgrades"
}
