# Suppress 'unused-variable'-warning for this file
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()


# Git-related constants
$global:FIFTY_CHARS = '|--------1---------2---------3---------4---------|'


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
  System_DarkYellow  = [COLOR]@{ hex = '#000000'; rgb = [RGB]@{r = 0; g = 0; b = 0; }; }
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


$global:colorChart = @{
  rainbow     = @{
    fg = @( $colors.PrideRed, $colors.PrideOrange, $colors.PrideYellow, $colors.PrideGreen, $colors.PrideBlue, $colors.PridePurple )
    bg = $null
  }
  trans       = @{
    fg = @( $colors.PrideCyan, $colors.PridePink, $colors.PrideWhite, $colors.PridePink, $colors.PrideCyan )
    bg = $null
  }
  bisexual    = @{
    fg = @( $colors.PrideBiPink, $colors.PrideBiPurple, $colors.PrideBiBlue )
    bg = $null
  }
  nonbinary   = @{
    fg = @( $colors.PrideNbYellow, $colors.PrideWhite, $colors.PrideNbPurple, $colors.PrideBlack )
    bg = $null
  }
  norway      = @{
    fg = @( $colors.Red, $colors.White, $colors.Blue, $colors.White, $colors.Red )
    bg = $null
  }
  blueRibbon  = @{
    fg = @( $colors.BlueRibbon )
    bg = $null
  }
  pinkRibbon  = @{
    fg = @( $colors.PinkRibbon )
    bg = $null
  }
  starWars    = @{
    fg = @( $colors.Yellow )
    bg = ( $colors.Black )
  }
  colorfull   = @{
    fg = @( $($global:colors.Values.GetEnumerator() | Select-Object -First 18))
    bg = $null
  }
  randomColor = @{
    fg = @( $($global:colors.Values.GetEnumerator() | Get-Random -Count 1))
    bg = $null
  }
}
