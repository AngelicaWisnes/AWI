
##############################
# Printing-related functions #
##############################

<#
  Example formatting for ansi- and rgb-colors:
  ANSI:   $([char]0x1b)[38;5;252m'Sample Text'$([char]0x1b)[0m
  RGB:    $([char]0x1b)[38;2;255;255;255m'Sample Text'$([char]0x1b)[0m

  Breakdown of the formatting:
  ANSI:   1111111111111 2 XX 2 Y 2 AAA             2 VVVVVVVVVVVVV 1111111111111 444
  ANSI:   $([char]0x1b) [ 38 ; 5 ; 252             m 'Sample Text' $([char]0x1b) [0m
  RGB:    $([char]0x1b) [ 38 ; 2 ; 255 ; 255 ; 255 m 'Sample Text' $([char]0x1b) [0m
  RGB:    1111111111111 2 XX 2 Y 2 RRR 3 GGG 3 BBB 2 VVVVVVVVVVVVV 1111111111111 444

  Where:
  1 = Escape-sequence
  2 = Common separators/elements for color-code
  3 = RGB-separators
  4 = Color-reset code
  X = 48 for background-color, OR 38 for foregrount-color
  Y = 5 for ansi-color, OR 2 for rgb-color
  V = The text to be colored
  A = The color-values for ANSI
  R, G, B = The color-values for RGB
#>


function Get-DadJoke { 
  If ($PSVersionTable.PSVersion.Major -eq 7) { Get-DadJoke_PowerShell7 }
  Else { Get-DadJoke_PowerShell5 }
}
Set-Alias dad Get-DadJoke
Add-ToFunctionList -category "Printing" -name 'dad' -value 'Print random dad-joke'


function Get-DadJoke_PowerShell5 { 
  $dadContent = Invoke-WebRequest https://icanhazdadjoke.com/
  $dadJoke = ($dadContent.AllElements | Where-Object { $_.Class -eq "subtitle" }).innerText
  OUT $(PE -txt:"$dadJoke" -fg:$global:colors.Cyan)
}


function Get-DadJoke_PowerShell7 { 
  [console]::ForegroundColor = 'Cyan'
  OUT
  curl https://icanhazdadjoke.com/
  OUT
  [console]::ResetColor()
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
    $cursorSave = (Get-Host).UI.RawUI.cursorsize
    (Get-Host).UI.RawUI.cursorsize = 0
    OUT

    for ( $n = 0; $n -lt $LoopCount; $n++ ) {
      for ( $i = 0; $i -lt $frames.count; $i++ ) {
        Write-Host -ForegroundColor Cyan "`r`t$($frames[$i])" -NoNewline
        Start-Sleep -Milliseconds $frameDelay
      }
    }
  }
  finally {
    (Get-Host).UI.RawUI.cursorsize = $cursorSave
    OUT
  }
}
Add-ToFunctionList -category "Printing" -name 'dance' -value 'See the PowerShell DanceSquad'


function Get-AllAnsiColors {
  Param ([switch]$Background)

  If ($Background) { $X = 48 }
  Else { $X = 38 }
  $esc = $global:COLOR_ESCAPE

  0..255 | ForEach-Object {
    $sample = "{0, 4}" -f $_
    $text = "$esc[$X;5;{0}m{1}$global:RESET_SEQUENCE" -f $_, $sample
    Write-Host $text -NoNewline
    If ( ($_ - 15) % 36 -eq 0 ) { Write-Host "" }
  }
}
Set-Alias allAnsi Get-AllAnsiColors
Add-ToFunctionList -category "Printing" -name 'allAnsi' -value 'See all available ansi-colors'


function Get-AllRGBColors {
  $sample = "   "

  $rs = 0..255
  $gs = 0..255
  $bs = 0..255

  for ($r = 0; $r -lt $rs.Count; $r += 15) {
    for ($g = 0; $g -lt $gs.Count; $g += 15) {
      for ($b = 0; $b -lt $bs.Count; $b += 15) {
        $rgb = [RGB]@{r = $r ; g = $g ; b = $b}
        OUT $(PE -txt:$sample -bg:$rgb) -NoNewlineStart -NoNewline
        If ( ($b + 1) % 256 -eq 0 ) { Write-Host "" }
      }
      If ( ($g + 1) % 256 -eq 0 ) { Write-Host "" }
    }
  }
}
Set-Alias allRgb Get-AllRGBColors
Add-ToFunctionList -category "Printing" -name 'allRgb' -value 'See all available RGB-colors'


function Get-ImplementedRGBColors {
  $sample = " " * 15
 
  foreach ($color in $colors.GetEnumerator()) {
    $rgb = Get-Rgb $color.value
    $colorName = "{0, 20} " -f $color.Name
    $hexAndRgbValue = " HEX: {0}   RGB: {1, 3}, {2, 3}, {3, 3}" -f $color.value.hex, $rgb.r, $rgb.g, $rgb.b

    OUT $(PE -txt:$colorName), $(PE -txt:$sample -bg:$rgb), $(PE -txt:$hexAndRgbValue)
  }
}
Set-Alias implColors Get-ImplementedRGBColors
Add-ToFunctionList -category "Printing" -name 'implColors' -value 'See implemented RGB-colors'



function Get-ColorCharts {
  $windowWidth, $_ = Get-WindowDimensions
  $spaceLength = (" " * $windowWidth)

  foreach ($chart in $global:colorChart.Values) {
    foreach ($color in $chart.fg) {
      OUT $(PE -txt:$spaceLength -bg:$color) -NoNewlineStart
    }
    Write-Host "`n`n"
}
}
Set-Alias implCharts Get-ColorCharts
Add-ToFunctionList -category "Printing" -name 'implCharts' -value 'See implemented color-charts'


function Get-ColorFromHEX {
  param ( [Parameter(Mandatory)][string]$hex )

  Return [COLOR]@{ hex = $hex; rgb = $null };
}


function Get-PrintElement {
  param ( [string]$txt, [Object]$fg, [Object]$bg )

  Return [PrintElement]@{
      text = $txt
      foreground = If ($fg -and $fg.GetType() -eq [RGB]) { $fg } Else { Get-Rgb -color:$fg }
      background = If ($bg -and $bg.GetType() -eq [RGB]) { $bg } Else { Get-Rgb -color:$bg }
  }
}
Set-Alias PE Get-PrintElement


function OUT {
  param( 
    [PrintElement[]]$printElements = @(),
    [switch]$NoNewline = $False,
    [switch]$NoNewlineStart = $False
  )

  $sb = [System.Text.StringBuilder]::new()

  If (-Not $NoNewlineStart -and $printElements.Count -gt 0) { [void]$sb.AppendLine() }
  
  Foreach ($element in $printElements) {
    If (-not $element.foreground -and -not $element.background) { [void]$sb.Append($element.text) }
    Else { [void]$sb.Append($(Get-RGBFormattedString -element:$element)) }
  }
    
  Write-Host $sb.ToString() -NoNewline:$NoNewline
}


function Get-RGBFormattedString {
  param([Parameter(Mandatory)][PrintElement]$element)
  If ($element.text.Length -eq 0) { Return "" }

  $colorSequence = Get-RgbStartSequence -fg:$element.foreground -bg:$element.background
  $lines = $element.text -split "`n"
  
  $formattedLines = Foreach ($line in $lines) { 
    $colorSequence + $line + $global:RESET_SEQUENCE 
  }
  
  Return $formattedLines -join "`n"
}


function Get-RgbStartSequence {
  param ( [RGB]$fg, [RGB]$bg )

  $fgSequence = If ($fg) { $global:RGB_COLOR_SEQUENCE -f "38", $fg.r, $fg.g, $fg.b }
  $bgSequence = If ($bg) { $global:RGB_COLOR_SEQUENCE -f "48", $bg.r, $bg.g, $bg.b }

  If ($fgSequence -and $bgSequence) { Return $global:RGB_SEQUENCE -f "$fgSequence;$bgSequence" } 
  elseif ($fgSequence) { Return $global:RGB_SEQUENCE -f $fgSequence } 
  elseif ($bgSequence) { Return $global:RGB_SEQUENCE -f $bgSequence } 
  else { Return "" }
}


function Get-Rgb {
  param( [COLOR]$color )

  If (-not $color) { Return $null }
  Elseif ($color.rgb) { Return $color.rgb }
  Else { Return Convert-HexToRgb $color }
}


function Convert-HexToRgb {
  param( [Parameter(Mandatory)][COLOR]$color )
  $hex = $color.hex
  
  $red = [convert]::ToInt32($hex.Substring(1, 2), 16)
  $green = [convert]::ToInt32($hex.Substring(3, 2), 16)
  $blue = [convert]::ToInt32($hex.Substring(5, 2), 16)

  Return [RGB]@{ r = $red ; g = $green ; b = $blue }
}


function Get-ColoredInput {
  try { 
    [console]::ForegroundColor = 'DarkCyan'
    $coloredInput = Read-Host 
  }
  finally { [console]::ResetColor() }

  Return $coloredInput
}

function TestHexColor {
  param ([Parameter(Mandatory)][string]$hex )
  $color = Get-ColorFromHEX -hex:$hex

  OUT $(PE -txt:"TESTING COLOR`n$hex`n" -fg:$color), $(PE -txt:"             " -bg:$color)
}
Set-Alias thc TestHexColor
Add-ToFunctionList -category "Printing" -name 'thc' -value 'Test hex color'