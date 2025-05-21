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
$Global:RGB_ESCAPE = "$([char]0x1b)"
If ($PSVersionTable.PSVersion.Major -gt 5) { $Global:RGB_ESCAPE = "`e" }


# Classes
class RGB {
  [int]$r
  [int]$g
  [int]$b
  [string]$fg
  [string]$bg
  
  RGB([hashtable]$params) {
    $this.r = $params.r
    $this.g = $params.g
    $this.b = $params.b
    $this.fg = '{0}[0m{0}[38;2;{1};{2};{3}m' -f $Global:RGB_ESCAPE, $this.r, $this.g, $this.b
    $this.bg = '{0}[0m{0}[48;2;{1};{2};{3}m' -f $Global:RGB_ESCAPE, $this.r, $this.g, $this.b
  }
}


# Colors
$Global:RGBs = [ordered]@{
  # Light colors
  Red                = [RGB]@{r = 255; g = 0; b = 0; }       #FF0000
  Orange             = [RGB]@{r = 255; g = 128; b = 0; }     #FF8000
  Yellow             = [RGB]@{r = 255; g = 255; b = 0; }     #FFFF00
  Chartreuse         = [RGB]@{r = 128; g = 255; b = 0; }     #80FF00
  Lime               = [RGB]@{r = 0; g = 255; b = 0; }       #00FF00
  SpringGreen        = [RGB]@{r = 0; g = 255; b = 128; }     #00FF80
  BlueRibbon         = [RGB]@{r = 173; g = 216; b = 230; }   #ADD8E6
  Cyan               = [RGB]@{r = 0; g = 255; b = 255; }     #00FFFF
  DarkCyan           = [RGB]@{r = 58; g = 150; b = 221; }    #3A96DD
  DodgerBlue         = [RGB]@{r = 0; g = 128; b = 255; }     #0080FF
  Blue               = [RGB]@{r = 0; g = 0; b = 255; }       #0000FF
  ElectricIndigo     = [RGB]@{r = 128; g = 0; b = 255; }     #8000FF
  Magenta            = [RGB]@{r = 255; g = 0; b = 255; }     #FF00FF
  DeepPink           = [RGB]@{r = 255; g = 0; b = 128; }     #FF0080
  MonaLisa           = [RGB]@{r = 255; g = 128; b = 128; }   #FF8080
  PinkRibbon         = [RGB]@{r = 255; g = 192; b = 203; }   #FFC0CB
  MintGreen          = [RGB]@{r = 128; g = 255; b = 128; }   #80FF80
  Jade               = [RGB]@{r = 0; g = 190; b = 100; }     #00BE64
  LightSlateBlue     = [RGB]@{r = 128; g = 128; b = 255; }   #8080FF
  # Dark colors
  Maroon             = [RGB]@{r = 128; g = 0; b = 0; }       #800000
  Olive              = [RGB]@{r = 128; g = 128; b = 0; }     #808000
  Green              = [RGB]@{r = 0; g = 128; b = 0; }       #008000
  Teal               = [RGB]@{r = 0; g = 128; b = 128; }     #008080
  Navy               = [RGB]@{r = 0; g = 0; b = 128; }       #000080
  Purple             = [RGB]@{r = 128; g = 0; b = 128; }     #800080
  # Contrasts
  White              = [RGB]@{r = 255; g = 255; b = 255; }   #FFFFFF
  Silver             = [RGB]@{r = 192; g = 192; b = 192; }   #C0C0C0
  Gray               = [RGB]@{r = 128; g = 128; b = 128; }   #808080
  Black              = [RGB]@{r = 0; g = 0; b = 0; }         #000000
  # SystemColors   Get their RGB values by foreach ($color in [System.ConsoleColor].GetEnumValues()) {[System.Drawing.Color]::FromName($color)}
  System_Black       = [RGB]@{r = 0; g = 0; b = 0; }         #000000
  System_DarkBlue    = [RGB]@{r = 0; g = 0; b = 139; }       #00008B
  System_DarkGreen   = [RGB]@{r = 0; g = 100; b = 0; }       #006400
  System_DarkCyan    = [RGB]@{r = 0; g = 139; b = 139; }     #008B8B
  System_DarkRed     = [RGB]@{r = 139; g = 0; b = 0; }       #8B0000
  System_DarkMagenta = [RGB]@{r = 139; g = 0; b = 139; }     #8B008B
  System_DarkYellow  = [RGB]@{r = 128; g = 128; b = 0; }     #808000
  System_Gray        = [RGB]@{r = 128; g = 128; b = 128; }   #808080
  System_DarkGray    = [RGB]@{r = 169; g = 169; b = 169; }   #A9A9A9
  System_Blue        = [RGB]@{r = 0; g = 0; b = 255; }       #0000FF
  System_Green       = [RGB]@{r = 0; g = 128; b = 0; }       #008000
  System_Cyan        = [RGB]@{r = 0; g = 255; b = 255; }     #00FFFF
  System_Red         = [RGB]@{r = 255; g = 0; b = 0; }       #FF0000
  System_Magenta     = [RGB]@{r = 255; g = 0; b = 255; }     #FF00FF
  System_Yellow      = [RGB]@{r = 255; g = 255; b = 0; }     #FFFF00
  System_White       = [RGB]@{r = 255; g = 255; b = 255; }   #FFFFFF
  # Color-names are taken from https://www.color-blindness.com/color-name-hue/
  # Hex-codes can visualize the corresponding color in VS-Code with this extension: https://marketplace.visualstudio.com/items?itemName=naumovs.color-highlight
  # Pride-specific codes
  PrideWhite         = [RGB]@{r = 255; g = 255; b = 255; }   #FFFFFF
  PridePink          = [RGB]@{r = 255; g = 175; b = 199; }   #FFAFC7
  PrideCyan          = [RGB]@{r = 115; g = 215; b = 238; }   #73D7EE
  PrideBrown         = [RGB]@{r = 97; g = 57; b = 21; }      #613915
  PrideBlack         = [RGB]@{r = 0; g = 0; b = 0; }         #000000
  PrideRed           = [RGB]@{r = 229; g = 0; b = 0; }       #E50000
  PrideOrange        = [RGB]@{r = 255; g = 141; b = 0; }     #FF8D00
  PrideYellow        = [RGB]@{r = 255; g = 238; b = 0; }     #FFEE00
  PrideGreen         = [RGB]@{r = 2; g = 129; b = 33; }      #028121
  PrideBlue          = [RGB]@{r = 0; g = 76; b = 255; }      #004CFF
  PridePurple        = [RGB]@{r = 115; g = 0; b = 136; }     #730088
  PrideBiPink        = [RGB]@{r = 176; g = 11; b = 105; }    #B00B69
  PrideBiPurple      = [RGB]@{r = 165; g = 94; b = 167; }    #A55EA7
  PrideBiBlue        = [RGB]@{r = 29; g = 28; b = 201; }     #1D1CC9
  PrideNbYellow      = [RGB]@{r = 255; g = 244; b = 51; }    #FFF433
  PrideNbPurple      = [RGB]@{r = 155; g = 89; b = 208; }    #9B59D0
}

$Global:RGB_RESET = "$Global:RGB_ESCAPE[0m"
$Global:RGB_INFO = $Global:RGBs.Cyan
$Global:RGB_SUCCESS = $Global:RGBs.Jade
$Global:RGB_FAIL = $Global:RGBs.Red
$Global:RGB_PROMPT = $Global:RGBs.Yellow
$Global:RGB_INIT = $Global:RGBs.White

$Global:RGBChart = [ordered]@{
  rainbow     = @{
    fg = @( $Global:RGBs.PrideRed, $Global:RGBs.PrideOrange, $Global:RGBs.PrideYellow, $Global:RGBs.PrideGreen, $Global:RGBs.PrideBlue, $Global:RGBs.PridePurple )
    bg = $null
  }
  trans       = @{
    fg = @( $Global:RGBs.PrideCyan, $Global:RGBs.PridePink, $Global:RGBs.PrideWhite, $Global:RGBs.PridePink, $Global:RGBs.PrideCyan )
    bg = $null
  }
  bisexual    = @{
    fg = @( $Global:RGBs.PrideBiPink, $Global:RGBs.PrideBiPurple, $Global:RGBs.PrideBiBlue )
    bg = $null
  }
  nonbinary   = @{
    fg = @( $Global:RGBs.PrideNbYellow, $Global:RGBs.PrideWhite, $Global:RGBs.PrideNbPurple, $Global:RGBs.PrideBlack )
    bg = $null
  }
  norway      = @{
    fg = @( $Global:RGBs.Red, $Global:RGBs.White, $Global:RGBs.Blue, $Global:RGBs.White, $Global:RGBs.Red )
    bg = $null
  }
  blueRibbon  = @{
    fg = @( $Global:RGBs.BlueRibbon )
    bg = $null
  }
  pinkRibbon  = @{
    fg = @( $Global:RGBs.PinkRibbon )
    bg = $null
  }
  starWars    = @{
    fg = @( $Global:RGBs.Yellow )
    bg = ( $Global:RGBs.Black )
  }
  colorfull   = @{
    fg = @( $($Global:RGBs.Values.GetEnumerator() | Select-Object -First 19))
    bg = $null
  }
  randomColor = @{
    fg = @( $($Global:RGBs.Values.GetEnumerator() | Get-Random -Count 1))
    bg = $null
  }
}



##########################
### Colorize Functions ###
##########################

function color_fg_bg {
  param (
    [Parameter(Position = 0)][RGB]$fc, 
    [Parameter(Position = 1)][RGB]$bc
  )
  If ($null -eq $fc -and $null -eq $bc) { Return '' }
  If ($null -ne $fc -and $null -eq $bc) { Return $fc.fg }
  If ($null -eq $fc -and $null -ne $bc) { Return $bc.bg }
  Return '{0}[0m{0}[38;2;{1};{2};{3};48;2;{4};{5};{6}m' -f $Global:RGB_ESCAPE, $fc.r, $fc.g, $fc.b, $bc.r, $bc.g, $bc.b
}

function color_focus {
  param ([string]$message)
  Return ('{0}{1}' -f $Global:RGBs.MintGreen.fg, $message)
}



###########################
### Write-Host Override ###
###########################

# Check if the original Write-Host is already saved
If (-not $OriginalWriteHost) { $OriginalWriteHost = Get-Command Write-Host }

# Define the new Write-Host function
function Write-Host {
  param (
    [Parameter(ValueFromRemainingArguments = $true)]
    $Message,
    [switch] $NoNewline
  )
  
  # Concatenate the message and the additional text
  $finalMessage = "$($Message -join ' ')$Global:RGB_ESCAPE[0m"

  # Call the original Write-Host with the concatenated message and parameters
  & $OriginalWriteHost -Object:$finalMessage -NoNewline:$NoNewline 
}

function Write-Initiate {
  param ([Parameter(Mandatory)][string]$message, [switch]$NoNewLine)
  Write-Host ("`n{0}Initiating - {1}" -f $Global:RGB_INIT.fg, $message) -NoNewline:$NoNewLine
}

function Write-Prompt {
  param ([Parameter(Mandatory)][string]$message, [switch]$NoNewLine)
  Write-Host ('{0}{1}' -f $Global:RGB_PROMPT.fg, $message) -NoNewline:$NoNewLine
}

function Write-Fail {
  param ([Parameter(Mandatory)][string]$message, [switch]$NoNewLine)
  Write-Host ("`n{0}Fail - {1}" -f $Global:RGB_FAIL.fg, $message) -NoNewline:$NoNewLine
}

function Write-Success {
  param ([Parameter(Mandatory)][string]$message, [switch]$NoNewLine)
  Write-Host ("`n{0}Success - {1}" -f $Global:RGB_SUCCESS.fg, $message) -NoNewline:$NoNewLine
}

function Write-Info {
  param ([Parameter(Mandatory)][string]$message, [switch]$NoNewLine)
  Write-Host ("`n{0}{1}" -f $Global:RGB_INFO.fg, $message) -NoNewline:$NoNewLine
}

function Write-Cancel {
  param ([string]$additionalMessage = '', [switch]$NoNewLine)
  Write-Host ("`n{0}Canceling... {1}" -f $Global:RGBs.Red.fg, $additionalMessage) -NoNewline:$NoNewLine
}

# Example usage
# Write-Host ('This {0}is {1}a{2} test' -f $Global:RGBs.Yellow.fg, $Global:RGBs.Yellow.bg, (color_fg_bg $Global:RGBs.ElectricIndigo $Global:RGBs.Gray))
