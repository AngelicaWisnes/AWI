
##############################
# Printing-related functions #
##############################

function Get-DadJoke {
  If ($PSVersionTable.PSVersion.Major -eq 7) { Get-DadJoke_PowerShell7 }
  Else { Get-DadJoke_PowerShell5 }
}
Set-Alias dad Get-DadJoke
Add-ToFunctionList -category 'Printing' -name 'dad' -value 'Print random dad-joke'


function Get-DadJoke_PowerShell5 {
  $dadContent = Invoke-WebRequest https://icanhazdadjoke.com/
  $dadJoke = ($dadContent.AllElements | Where-Object { $_.Class -eq 'subtitle' }).innerText
  Write-Info "$dadJoke"
}


function Get-DadJoke_PowerShell7 {
  $dadJoke = curl https://icanhazdadjoke.com/ 2>$null
  Write-Info "$dadJoke"
}


function dance {
  $frames = @(
    "(>'-')>   ^('-')^   <('-'<)" ,
    "^('-')^   <('-')>   ^('-')^" ,
    "<('-'<)   ^('-')^   (>'-')>" ,
    "^('-')^   <('-')>   ^('-')^"
  )
  $loopCount = 10    # number of animation sets
  $frameDelay = 200   # milliseconds

  try {
    $cursorSave = (Get-Host).UI.RawUI.CursorSize
    (Get-Host).UI.RawUI.CursorSize = 0
    Write-Host

    for ( $n = 0; $n -lt $LoopCount; $n++ ) {
      for ( $i = 0; $i -lt $frames.count; $i++ ) {
        Write-Host ("`r`t{0}{1}" -f $Global:RGBs.Cyan.fg, $($frames[$i])) -NoNewline
        Start-Sleep -Milliseconds $frameDelay
      }
    }
  }
  finally {
    (Get-Host).UI.RawUI.CursorSize = $cursorSave
    Write-Host
  }
}
Add-ToFunctionList -category 'Printing' -name 'dance' -value 'See the PowerShell DanceSquad'


function Get-AllAnsiColors {
  Param ([switch]$Background)

  If ($Background) { $X = 48 }
  Else { $X = 38 }
  $esc = $Global:RGB_ESCAPE
  $reset = $Global:RGB_RESET
  0..255 | ForEach-Object {
    $sample = '{0, 4}' -f $_
    $text = "$esc[$X;5;{0}m{1}$reset" -f $_, $sample
    Write-Host $text -NoNewline
    If ( ($_ - 15) % 36 -eq 0 ) { Write-Host '' }
  }
}
Set-Alias allAnsi Get-AllAnsiColors
Add-ToFunctionList -category 'Printing' -name 'allAnsi' -value 'See all available ansi-colors'


function Get-AllRGBColors {
  $sample = '   '

  $rs = 0..255
  $gs = 0..255
  $bs = 0..255

  for ($r = 0; $r -lt $rs.Count; $r += 15) {
    for ($g = 0; $g -lt $gs.Count; $g += 15) {
      for ($b = 0; $b -lt $bs.Count; $b += 15) {
        $rgb = [RGB]@{r = $r ; g = $g ; b = $b }
        Write-Host ('{0}{1}' -f $rgb.bg, $sample) -NoNewline

        If ( ($b + 1) % 256 -eq 0 ) { Write-Host '' }
      }
      If ( ($g + 1) % 256 -eq 0 ) { Write-Host '' }
    }
  }
}
Set-Alias allRgb Get-AllRGBColors
Add-ToFunctionList -category 'Printing' -name 'allRgb' -value 'See all available RGB-colors'


function Get-ImplementedRGBColors {
  $sample = ' ' * 15

  foreach ($RGB in $Global:RGBs.GetEnumerator()) {
    $c = $RGB.value
    Write-Host ('{0, 20} RGB: {1, 3}, {2, 3}, {3, 3}  {4}Sample TEXT {5}{6}' -f $RGB.Name, $c.r, $c.g, $c.b, $c.fg, $c.bg, $sample)
  }
}
Set-Alias implRGBs Get-ImplementedRGBColors
Add-ToFunctionList -category 'Printing' -name 'implRGBs' -value 'See implemented RGB-colors'



function Get-ColorCharts {
  $windowWidth, $_ = Get-WindowDimensions
  $spaceLength = (' ' * $windowWidth)

  foreach ($chart in $Global:RGBChart.GetEnumerator()) {
    OUT $(PE -txt:$chart.Name)
    foreach ($color in $chart.value.fg) {
      Write-Host ('{0}{1}' -f $color.bg, $spaceLength)
    }
    Write-Host "`n`n"
  }
}
Set-Alias implCharts Get-ColorCharts
Add-ToFunctionList -category 'Printing' -name 'implCharts' -value 'See implemented color-charts'


function Get-ColoredInput {
  try {
    [console]::ForegroundColor = 'DarkCyan'
    $coloredInput = Read-Host
  }
  finally { [console]::ResetColor() }

  Return $coloredInput
}


function Convert-HexToRgb {
  param( [Parameter(Mandatory)][string]$hex )

  $red = [convert]::ToInt32($hex.Substring(1, 2), 16)
  $green = [convert]::ToInt32($hex.Substring(3, 2), 16)
  $blue = [convert]::ToInt32($hex.Substring(5, 2), 16)

  Return [RGB]@{ r = $red ; g = $green ; b = $blue }
}


function Test-HexColor {
  param ([Parameter(Mandatory)][string]$hex )
  $rgb = Convert-HexToRgb $hex
  Write-Host ("`n{0} = [RGB]{{@r = {1, 3}; g = {2, 3}; b = {3, 3}; }}   {4}Sample TEXT {5}`t`t" -f $hex, $rgb.r, $rgb.g, $rgb.b, $rgb.fg, $rgb.bg)
}
Set-Alias thc TestHexColor
Add-ToFunctionList -category 'Printing' -name 'thc' -value 'Test hex color'
