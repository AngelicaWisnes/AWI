
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
  X = 48 for background-color, OR 38 for foreground-color
  Y = 5 for ansi-color, OR 2 for rgb-color
  V = The text to be colored
  A = The color-values for ANSI
  R, G, B = The color-values for RGB
#>


# Print-related constants
$global:COLOR_ESCAPE = "$([char]0x1b)"
If ($PSVersionTable.PSVersion.Major -gt 5) { $global:COLOR_ESCAPE = "`e" }
$global:RGB_SEQUENCE = "$global:COLOR_ESCAPE[{0}m"
$global:RGB_COLOR_SEQUENCE = '{0};2;{1};{2};{3}'
$global:RESET_SEQUENCE = "$global:RGB_SEQUENCE" -f '0'

# Classes
class RGB { [int]$r; [int]$g; [int]$b; }
class COLOR { [string]$hex; [RGB]$rgb }
class PrintElement { [string]$text; [RGB]$foreground; [RGB]$background; }



# Colors
$global:colors = [ordered]@{
  # Light colors
  Red                = [COLOR]@{ hex = '#FF0000'; rgb = [RGB]@{r = 255; g = 0; b = 0; }; }
  Orange             = [COLOR]@{ hex = '#FF8000'; rgb = [RGB]@{r = 255; g = 128; b = 0; }; }
  Yellow             = [COLOR]@{ hex = '#FFFF00'; rgb = [RGB]@{r = 255; g = 255; b = 0; }; }
  Chartreuse         = [COLOR]@{ hex = '#80FF00'; rgb = [RGB]@{r = 128; g = 255; b = 0; }; }
  Lime               = [COLOR]@{ hex = '#00FF00'; rgb = [RGB]@{r = 0; g = 255; b = 0; }; }
  SpringGreen        = [COLOR]@{ hex = '#00FF80'; rgb = [RGB]@{r = 0; g = 255; b = 128; }; }
  BlueRibbon         = [COLOR]@{ hex = '#ADD8E6'; rgb = [RGB]@{r = 173; g = 216; b = 230; }; }
  Cyan               = [COLOR]@{ hex = '#00FFFF'; rgb = [RGB]@{r = 0; g = 255; b = 255; }; }
  DarkCyan           = [COLOR]@{ hex = '#3A96DD'; rgb = [RGB]@{r = 58; g = 150; b = 221; }; }
  DodgerBlue         = [COLOR]@{ hex = '#0080FF'; rgb = [RGB]@{r = 0; g = 128; b = 255; }; }
  Blue               = [COLOR]@{ hex = '#0000FF'; rgb = [RGB]@{r = 0; g = 0; b = 255; }; }
  ElectricIndigo     = [COLOR]@{ hex = '#8000FF'; rgb = [RGB]@{r = 128; g = 0; b = 255; }; }
  Magenta            = [COLOR]@{ hex = '#FF00FF'; rgb = [RGB]@{r = 255; g = 0; b = 255; }; }
  DeepPink           = [COLOR]@{ hex = '#FF0080'; rgb = [RGB]@{r = 255; g = 0; b = 128; }; }
  MonaLisa           = [COLOR]@{ hex = '#FF8080'; rgb = [RGB]@{r = 255; g = 128; b = 128; }; }
  PinkRibbon         = [COLOR]@{ hex = '#FFC0CB'; rgb = [RGB]@{r = 255; g = 192; b = 203; }; }
  MintGreen          = [COLOR]@{ hex = '#80FF80'; rgb = [RGB]@{r = 128; g = 255; b = 128; }; }
  Jade               = [COLOR]@{ hex = '#00BE64'; rgb = [RGB]@{r = 0; g = 190; b = 100; }; }
  LightSlateBlue     = [COLOR]@{ hex = '#8080FF'; rgb = [RGB]@{r = 128; g = 128; b = 255; }; }
  # Dark colors
  Maroon             = [COLOR]@{ hex = '#800000'; rgb = [RGB]@{r = 128; g = 0; b = 0; }; }
  Olive              = [COLOR]@{ hex = '#808000'; rgb = [RGB]@{r = 128; g = 128; b = 0; }; }
  Green              = [COLOR]@{ hex = '#008000'; rgb = [RGB]@{r = 0; g = 128; b = 0; }; }
  Teal               = [COLOR]@{ hex = '#008080'; rgb = [RGB]@{r = 0; g = 128; b = 128; }; }
  Navy               = [COLOR]@{ hex = '#000080'; rgb = [RGB]@{r = 0; g = 0; b = 128; }; }
  Purple             = [COLOR]@{ hex = '#800080'; rgb = [RGB]@{r = 128; g = 0; b = 128; }; }
  # Contrasts
  White              = [COLOR]@{ hex = '#FFFFFF'; rgb = [RGB]@{r = 255; g = 255; b = 255; }; }
  Silver             = [COLOR]@{ hex = '#C0C0C0'; rgb = [RGB]@{r = 192; g = 192; b = 192; }; }
  Gray               = [COLOR]@{ hex = '#808080'; rgb = [RGB]@{r = 128; g = 128; b = 128; }; }
  Black              = [COLOR]@{ hex = '#000000'; rgb = [RGB]@{r = 0; g = 0; b = 0; }; }
  # SystemColors   Get their RGB values by foreach ($color in [System.ConsoleColor].GetEnumValues()) {[System.Drawing.Color]::FromName($color)}
  System_Black       = [COLOR]@{ hex = '#000000'; rgb = [RGB]@{r = 0; g = 0; b = 0; }; }
  System_DarkBlue    = [COLOR]@{ hex = '#00008B'; rgb = [RGB]@{r = 0; g = 0; b = 139; }; }
  System_DarkGreen   = [COLOR]@{ hex = '#006400'; rgb = [RGB]@{r = 0; g = 100; b = 0; }; }
  System_DarkCyan    = [COLOR]@{ hex = '#008B8B'; rgb = [RGB]@{r = 0; g = 139; b = 139; }; }
  System_DarkRed     = [COLOR]@{ hex = '#8B0000'; rgb = [RGB]@{r = 139; g = 0; b = 0; }; }
  System_DarkMagenta = [COLOR]@{ hex = '#8B008B'; rgb = [RGB]@{r = 139; g = 0; b = 139; }; }
  System_DarkYellow  = [COLOR]@{ hex = '#808000'; rgb = [RGB]@{r = 128; g = 128; b = 0; }; }
  System_Gray        = [COLOR]@{ hex = '#808080'; rgb = [RGB]@{r = 128; g = 128; b = 128; }; }
  System_DarkGray    = [COLOR]@{ hex = '#A9A9A9'; rgb = [RGB]@{r = 169; g = 169; b = 169; }; }
  System_Blue        = [COLOR]@{ hex = '#0000FF'; rgb = [RGB]@{r = 0; g = 0; b = 255; }; }
  System_Green       = [COLOR]@{ hex = '#008000'; rgb = [RGB]@{r = 0; g = 128; b = 0; }; }
  System_Cyan        = [COLOR]@{ hex = '#00FFFF'; rgb = [RGB]@{r = 0; g = 255; b = 255; }; }
  System_Red         = [COLOR]@{ hex = '#FF0000'; rgb = [RGB]@{r = 255; g = 0; b = 0; }; }
  System_Magenta     = [COLOR]@{ hex = '#FF00FF'; rgb = [RGB]@{r = 255; g = 0; b = 255; }; }
  System_Yellow      = [COLOR]@{ hex = '#FFFF00'; rgb = [RGB]@{r = 255; g = 255; b = 0; }; }
  System_White       = [COLOR]@{ hex = '#FFFFFF'; rgb = [RGB]@{r = 255; g = 255; b = 255; }; }
  # Color-names are taken from https://www.color-blindness.com/color-name-hue/
  # Hex-codes can visualize the corresponding color in VS-Code with this extension: https://marketplace.visualstudio.com/items?itemName=naumovs.color-highlight
  # Pride-specific codes
  PrideWhite         = [COLOR]@{ hex = '#FFFFFF'; rgb = [RGB]@{r = 255; g = 255; b = 255; }; }
  PridePink          = [COLOR]@{ hex = '#FFAFC7'; rgb = [RGB]@{r = 255; g = 175; b = 199; }; }
  PrideCyan          = [COLOR]@{ hex = '#73D7EE'; rgb = [RGB]@{r = 115; g = 215; b = 238; }; }
  PrideBrown         = [COLOR]@{ hex = '#613915'; rgb = [RGB]@{r = 97; g = 57; b = 21; }; }
  PrideBlack         = [COLOR]@{ hex = '#000000'; rgb = [RGB]@{r = 0; g = 0; b = 0; }; }
  PrideRed           = [COLOR]@{ hex = '#E50000'; rgb = [RGB]@{r = 229; g = 0; b = 0; }; }
  PrideOrange        = [COLOR]@{ hex = '#FF8D00'; rgb = [RGB]@{r = 255; g = 141; b = 0; }; }
  PrideYellow        = [COLOR]@{ hex = '#FFEE00'; rgb = [RGB]@{r = 255; g = 238; b = 0; }; }
  PrideGreen         = [COLOR]@{ hex = '#028121'; rgb = [RGB]@{r = 2; g = 129; b = 33; }; }
  PrideBlue          = [COLOR]@{ hex = '#004CFF'; rgb = [RGB]@{r = 0; g = 76; b = 255; }; }
  PridePurple        = [COLOR]@{ hex = '#730088'; rgb = [RGB]@{r = 115; g = 0; b = 136; }; }
  PrideBiPink        = [COLOR]@{ hex = '#B00B69'; rgb = [RGB]@{r = 176; g = 11; b = 105; }; }
  PrideBiPurple      = [COLOR]@{ hex = '#A55EA7'; rgb = [RGB]@{r = 165; g = 94; b = 167; }; }
  PrideBiBlue        = [COLOR]@{ hex = '#1D1CC9'; rgb = [RGB]@{r = 29; g = 28; b = 201; }; }
  PrideNbYellow      = [COLOR]@{ hex = '#FFF433'; rgb = [RGB]@{r = 255; g = 244; b = 51; }; }
  PrideNbPurple      = [COLOR]@{ hex = '#9B59D0'; rgb = [RGB]@{r = 155; g = 89; b = 208; }; }
}

function Get-DadJoke {
  If ($PSVersionTable.PSVersion.Major -eq 7) { Get-DadJoke_PowerShell7 }
  Else { Get-DadJoke_PowerShell5 }
}
Set-Alias dad Get-DadJoke
Add-ToFunctionList -category 'Printing' -name 'dad' -value 'Print random dad-joke'


function Get-DadJoke_PowerShell5 {
  $dadContent = Invoke-WebRequest https://icanhazdadjoke.com/
  $dadJoke = ($dadContent.AllElements | Where-Object { $_.Class -eq 'subtitle' }).innerText
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
    $cursorSave = (Get-Host).UI.RawUI.CursorSize
    (Get-Host).UI.RawUI.CursorSize = 0
    OUT

    for ( $n = 0; $n -lt $LoopCount; $n++ ) {
      for ( $i = 0; $i -lt $frames.count; $i++ ) {
        Write-Host -ForegroundColor Cyan "`r`t$($frames[$i])" -NoNewline
        Start-Sleep -Milliseconds $frameDelay
      }
    }
  }
  finally {
    (Get-Host).UI.RawUI.CursorSize = $cursorSave
    OUT
  }
}
Add-ToFunctionList -category 'Printing' -name 'dance' -value 'See the PowerShell DanceSquad'


function Get-AllAnsiColors {
  Param ([switch]$Background)

  If ($Background) { $X = 48 }
  Else { $X = 38 }
  $esc = $global:COLOR_ESCAPE

  0..255 | ForEach-Object {
    $sample = '{0, 4}' -f $_
    $text = "$esc[$X;5;{0}m{1}$global:RESET_SEQUENCE" -f $_, $sample
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
        OUT $(PE -txt:$sample -bg:$rgb) -NoNewlineStart -NoNewline
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

  foreach ($color in $colors.GetEnumerator()) {
    $rgb = Get-Rgb $color.value
    $colorName = '{0, 20} ' -f $color.Name
    $hexAndRgbValue = 'HEX: {0}   RGB: {1, 3}, {2, 3}, {3, 3}' -f $color.value.hex, $rgb.r, $rgb.g, $rgb.b

    OUT $(PE -txt:$colorName), $(PE -txt:$sample -bg:$rgb), $(PE -txt:"`tSample TEXT`t" -fg:$rgb), $(PE -txt:$hexAndRgbValue)
  }
}
Set-Alias implColors Get-ImplementedRGBColors
Add-ToFunctionList -category 'Printing' -name 'implColors' -value 'See implemented RGB-colors'



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


function Get-ColorFromHEX {
  param ( [Parameter(Mandatory)][string]$hex )

  Return [COLOR]@{ hex = $hex; rgb = $null }
}


function Get-PrintElement {
  param ( [string]$txt, [Object]$fg, [Object]$bg )

  Return [PrintElement]@{
    text       = $txt
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
  If ($element.text.Length -eq 0) { Return '' }

  $colorSequence = Get-RgbStartSequence -fg:$element.foreground -bg:$element.background
  $lines = $element.text -split "`n"

  $formattedLines = Foreach ($line in $lines) {
    $colorSequence + $line + $global:RESET_SEQUENCE
  }

  Return $formattedLines -join "`n"
}


function Get-RgbStartSequence {
  param ( [RGB]$fg, [RGB]$bg )

  $fgSequence = If ($fg) { $global:RGB_COLOR_SEQUENCE -f '38', $fg.r, $fg.g, $fg.b }
  $bgSequence = If ($bg) { $global:RGB_COLOR_SEQUENCE -f '48', $bg.r, $bg.g, $bg.b }

  If ($fgSequence -and $bgSequence) { Return $global:RGB_SEQUENCE -f "$fgSequence;$bgSequence" }
  Elseif ($fgSequence) { Return $global:RGB_SEQUENCE -f $fgSequence }
  Elseif ($bgSequence) { Return $global:RGB_SEQUENCE -f $bgSequence }
  Else { Return '' }
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
  $rgb = Convert-HexToRgb -color:$color

  OUT $(PE -txt:"TESTING COLOR`n$hex`n R: $($rgb.r)   -   G: $($rgb.g)   -   B: $($rgb.b)`n" -fg:$color), $(PE -txt:'             ' -bg:$color)
}
Set-Alias thc TestHexColor
Add-ToFunctionList -category 'Printing' -name 'thc' -value 'Test hex color'
