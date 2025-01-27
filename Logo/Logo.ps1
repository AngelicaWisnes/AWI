
$logoRoot = $PSScriptRoot
$logo = "$logoRoot\Images\AW_LOGO_IMAGE.png" | Resolve-Path
$logo_text = "$logoRoot\Images\AW_LOGO_TEXT.txt" | Resolve-Path
$selfie_image = "$logoRoot\Images\W_SELFIE_IMAGE.png" | Resolve-Path
$selfie_text = "$logoRoot\Images\W_SELFIE_TEXT.txt" | Resolve-Path
$heart_text = "$logoRoot\Images\HEART_TEXT.txt" | Resolve-Path

function Convert-ImageToAsciiArt {
  param(
    [Parameter(Mandatory)][String] $Path,
    [bool]$BinaryPixelated = $false
  )

  Add-Type -AssemblyName System.Drawing # Load drawing functionality
  $imageFromFile = [Drawing.Image]::FromFile($path)
  $characters = (& { If ($BinaryPixelated) { '# ' } Else { '$#H&@*+;:-,. ' } }).ToCharArray() # Characters from dark to light
  $charCount = $characters.count

  $charHeightWidthRatio = 2 # A pixel has a H/W-ratio of 1/1, while a char has a H/W-ratio of 2/1
  $inputWidth = $imageFromFile.Width
  $inputHeight = $imageFromFile.Height / $charHeightWidthRatio

  $_, $outputWidth, $outputHeight = Get-OutputSizes @($inputWidth, $inputHeight)

  $bitmap = New-Object Drawing.Bitmap($imageFromFile , $outputWidth, $outputHeight)

  $sb = [System.Text.StringBuilder]::new()
  [void]$sb.AppendLine()

  for ($y = 0; $y -lt $outputHeight; $y++) {
    for ($x = 0; $x -lt $outputWidth; $x++) {
      $color = $bitmap.GetPixel($x, $y)
      $brightness = $color.GetBrightness()

      $offset = [Math]::Floor($brightness * $charCount)
      $ch = $characters[$offset]
      If (-not $ch) { $ch = $characters[-1] }

      [void]$sb.Append($ch)
    }
    [void]$sb.AppendLine()
  }

  $imageFromFile.Dispose()
  Return $sb.ToString()
}


function Resize-AsciiArt {
  param(
    [Parameter(Mandatory)][String] $Path,
    [int[]] $widthHeightDivisors = @(1, 1)
  )

  [string[]]$imageArrayFromFile = Get-Content -Path $Path

  $inputWidth = $imageArrayFromFile[0].Length
  $inputHeight = $imageArrayFromFile.Length

  $outputScale, $outputWidth, $outputHeight = Get-OutputSizes @($inputWidth, $inputHeight) $widthHeightDivisors

  $sb = [System.Text.StringBuilder]::new()
  [void]$sb.AppendLine()

  # Nearest-neighbor interpolation
  for ($y = 0; $y -lt $outputHeight; $y++) {
    $nearestY = [Math]::Floor($y / $outputScale)
    $line = $imageArrayFromFile[$nearestY]

    for ($x = 0; $x -lt $outputWidth; $x++) {
      $nearestX = [Math]::Floor($x / $outputScale)
      $pixel = $line.Substring($nearestX, 1)
      [void]$sb.Append($pixel)
    }
    [void]$sb.AppendLine()
  }

  Return $sb.ToString()
}


function Get-OutputSizes {
  param(
    [Parameter(Mandatory)][int[]] $inputDimensions,
    [int[]] $widthHeightDivisors = @(1, 1)
  )
  $inputWidth, $inputHeight = $inputDimensions

  $windowWidth, $windowHeight = Get-WindowDimensions
  $adjustedWindowWidth = $windowWidth / $widthHeightDivisors[0]
  $adjustedWindowHeight = $windowHeight / $widthHeightDivisors[1]

  $minScaleWidth = $adjustedWindowWidth / $inputWidth
  $minScaleHeight = $adjustedWindowHeight / $inputHeight

  $outputScale = [Math]::Min($minScaleWidth, $minScaleHeight)
  $outputWidth = [Math]::Floor($inputWidth * $outputScale)
  $outputHeight = [Math]::Floor($inputHeight * $outputScale)

  Return @($outputScale, $outputWidth, $outputHeight)
}


function Get-Logo {
  $colorChartString, $explanation = Get-ColorChartStringAndExplanation

  Get-HeartStampedLogo -logoColorChartString:$colorChartString
  Get-Explanation -expl:$explanation
  Get-RainbowSlimLine
  Get-TransSlimLine -NoNewlineStart
}
Add-ToFunctionList -category 'Other' -name 'Get-Logo' -value 'Get Logo'


function Get-ColorChartStringAndExplanation {
  switch -Regex (Get-Date -Format 'dd.MM') {
    '23.01' { $colorChartString = 'norway'; $explanation = 'Birthday'; Break }
    '24.01' { $colorChartString = 'norway'; $explanation = 'Birthday'; Break }
    '.*.01' { $colorChartString = 'colorfull'; $explanation = 'What a colorful new year!'; Break }
    '31.03' { $colorChartString = 'trans'; $explanation = 'International Transgender Day Of Visibility'; Break }
    '09.04' { $colorChartString = 'norway'; $explanation = 'Birthday'; Break }
    '04.05' { $colorChartString = 'starWars'; $explanation = 'May the 4th be with you'; Break }
    '.*.05' { $colorChartString = 'norway'; $explanation = 'Norwegian National Day (May 17th)'; Break }
    '.*.06' { $colorChartString = 'rainbow'; $explanation = 'Pride Month'; Break }
    '.*.07' { $colorChartString = 'nonbinary'; $explanation = 'Nonbinary Awareness Week (approx. 14th)'; Break }
    '^(?:0[0-9])\.09$' { $colorChartString = 'blueRibbon'; $explanation = 'Prostate Cancer Awareness Month'; Break }
    '.*.09' { $colorChartString = 'bisexual'; $explanation = 'Bisexual Awareness Week (approx. 16th-23rd)'; Break }
    '.*.10' { $colorChartString = 'pinkRibbon'; $explanation = 'Breast Cancer Awareness Month'; Break }
    '.*.11' { $colorChartString = 'trans'; $explanation = 'Trans Awareness Month'; Break }
    default { $colorChartString = 'randomColor'; $explanation = ''; Break }
  }

  Return $colorChartString, $explanation
}


function Get-AllLogoColors {
  Get-ArtRGB -colorChartString:'norway'
  Get-ArtRGB -colorChartString:'rainbow'
  Get-ArtRGB -colorChartString:'nonbinary'
  Get-ArtRGB -colorChartString:'bisexual'
  Get-ArtRGB -colorChartString:'trans'
  Get-ArtRGB -colorChartString:'pinkRibbon'
  Get-ArtRGB -colorChartString:'blueRibbon'
  Get-ArtRGB -colorChartString:'starWars'
  Get-ArtRGB -colorChartString:'colorfull'
  Get-ArtRGB -colorChartString:'randomColor'
}
Add-ToFunctionList -category 'Other' -name 'Get-AllLogoColors' -value 'Get all Logo colors'


function Get-ArtRGB {
  param(
    [string][string]$colorChartString,
    [string]$outputString = $(Get-LogoAsString)
  )
  $lines = $outputString.Split("`n")

  If ($colorChartString) {
    $fg_colorNumber = -1
    $fg_colors = $Global:RGBChart[$colorChartString].fg
    $fg_linesOfEachColor = If ($fg_colors) { [int]($lines.Count / $fg_colors.Count) }
    $fg_numberOfColors = $fg_colors.Count - 1

    $bg_colorNumber = -1
    $bg_colors = $Global:RGBChart[$colorChartString].bg
    $bg_linesOfEachColor = If ($bg_colors) { [int]($lines.Count / $bg_colors.Count) }
    $bg_numberOfColors = $bg_colors.Count - 1
  }

  for ($i = 0; $i -lt $lines.Count; $i++) {
    If ($fg_colors) {
      $fg_color = If ( $i % $fg_linesOfEachColor -eq 0 -and $fg_colorNumber -lt $fg_numberOfColors ) { $fg_colors[++$fg_colorNumber] } Else { $fg_colors[$fg_colorNumber] }
    }
    If ($bg_colors) {
      $bg_color = If ( $i % $bg_linesOfEachColor -eq 0 -and $bg_colorNumber -lt $bg_numberOfColors ) { $bg_colors[++$bg_colorNumber] } Else { $bg_colors[$bg_colorNumber] }
    } 

    Write-Host ('{0}{1}' -f (cfbg $fg_color $bg_color), $lines[$i])
  }
}


function Get-Selfie {
  Write-Host (Get-SelfieAsString)
}
Add-ToFunctionList -category 'Other' -name 'Get-Selfie' -value 'Get selfie'


function Get-SelfieAsString {
  $selfieImageExists = Test-Path -Path $selfie_image -PathType Leaf
  $selfieTextExists = Test-Path -Path $selfie_text -PathType Leaf

  If ($global:SYSTEM_OS.Contains('Windows') -and $selfieImageExists) {
    Return Convert-ImageToAsciiArt -Path $selfie_image
  }
  Elseif ($selfieTextExists) { Return Resize-AsciiArt -Path:$selfie_text }
  Else { Return 'Could not print selfie, as the file is missing' }
}


function Get-LogoAsString {
  $logoImageExists = Test-Path -Path $logo -PathType Leaf
  $logoTextExists = Test-Path -Path $logo_text -PathType Leaf

  If ($global:SYSTEM_OS.Contains('Windows') -and $logoImageExists) {
    Return Convert-ImageToAsciiArt -Path $logo -BinaryPixelated $true
  }
  Elseif ($logoTextExists) { Return Resize-AsciiArt -Path:$logo_text }
  Else { Return 'Could not print logo, as the file is missing' }
}


function Get-Explanation {
  param( [string]$expl )
  If (-not $expl) { Return }
  $windowWidth, $_ = Get-WindowDimensions
  Write-Host ('{0}{1}' -f (cfg $Global:RGBs.DeepPink), $expl.PadLeft($windowWidth))
}


function Get-HeartAsString {
  $heartTextExists = Test-Path -Path $heart_text -PathType Leaf

  If ($heartTextExists) { Return Resize-AsciiArt -Path:$heart_text -widthHeightDivisors:@(5, 3) }
}


function Get-HeartStampedLogo {
  param ([Parameter(Mandatory)][string]$logoColorChartString)
  $heartColorChartString = If ($logoColorChartString -eq 'trans') { 'rainbow' } Else { 'trans' }

  $logoLines, $heartLines = Get-MergedHeartLogoAsList

  # Handle logo-color
  $fg_logo_colorNumber = -1
  $fg_logo_colors = $Global:RGBChart[$logoColorChartString].fg
  $fg_logo_linesOfEachColor = If ($null -ne $fg_logo_colors) { [Math]::Max(1, [Math]::floor($logoLines.Count / $fg_logo_colors.Count)) }
  $fg_logo_numberOfColors = $fg_logo_colors.Count - 1

  $bg_logo_colorNumber = -1
  $bg_logo_colors = $Global:RGBChart[$logoColorChartString].bg
  $bg_logo_linesOfEachColor = If ($null -ne $bg_logo_colors) { [Math]::Max(1, [Math]::floor($logoLines.Count / $bg_logo_colors.Count)) }
  $bg_logo_numberOfColors = $bg_logo_colors.Count - 1

  # Handle heart-color
  $fg_heart_colorNumber = -1
  $fg_heart_colors = $Global:RGBChart[$heartColorChartString].fg
  $fg_heart_linesOfEachColor = If ($null -ne $fg_heart_colors) { [Math]::Max(1, [Math]::floor($heartLines.Count / $fg_heart_colors.Count)) }
  $fg_heart_numberOfColors = $fg_heart_colors.Count - 1

  $bg_heart_colorNumber = -1
  $bg_heart_colors = $Global:RGBChart[$heartColorChartString].bg
  $bg_heart_linesOfEachColor = If ($null -ne $bg_heart_colors) { [Math]::Max(1, [Math]::floor($heartLines.Count / $bg_heart_colors.Count)) }
  $bg_heart_numberOfColors = $bg_heart_colors.Count - 1


  for ($i = 0; $i -lt $logoLines.Count; $i++) {
    # Handle logo-color
    If ( $fg_logo_colors ) {
      If ( $i % $fg_logo_linesOfEachColor -eq 0 -and $fg_logo_colorNumber -lt $fg_logo_numberOfColors ) { $fg_logo_colorNumber++ }
      $fg_logo_color = $fg_logo_colors[$fg_logo_colorNumber]
    } 

    If ( $bg_logo_colors ) {
      If ( $i % $bg_logo_linesOfEachColor -eq 0 -and $bg_logo_colorNumber -lt $bg_logo_numberOfColors ) { $bg_logo_colorNumber++ }
      $bg_logo_color = $bg_logo_colors[$bg_logo_colorNumber]
    } 
    
    # Handle heart-color
    # Do not try to colorize the two first lines (heightOffset)
    If ( $fg_heart_colors -and $i -gt 2 ) {
      If ( ($i - 3) % $fg_heart_linesOfEachColor -eq 0 -and $fg_heart_colorNumber -lt $fg_heart_numberOfColors ) { $fg_heart_colorNumber++ }
      $fg_heart_color = $fg_heart_colors[$fg_heart_colorNumber]
    } 

    If ( $bg_heart_colors -and $i -gt 2 ) {
      If ( ($i - 3) % $bg_heart_linesOfEachColor -eq 0 -and $bg_heart_colorNumber -lt $bg_heart_numberOfColors ) { $bg_heart_colorNumber++ }
      $bg_heart_color = $bg_heart_colors[$bg_heart_colorNumber]
    }

    # Split the string based on consecutive occurrences of "H", " ", and "#"
    $lineSegments = $logoLines[$i] -split '([H]+|[ #]+)' | Where-Object { $_ -match '^[H# ]+$' }

    $lineSegments | ForEach-Object {
      $isHeart = $_.Substring(0, 1) -eq 'H'
      $fg_color = If ($isHeart) { $fg_heart_color } Else { $fg_logo_color }
      $bg_color = If ($isHeart) { $bg_heart_color } Else { $bg_logo_color }
      Write-Host ('{0}{1}' -f (cfbg $fg_color $bg_color), $_) -NoNewline
    }
    Write-Host 
  }
}

function Get-MergedHeartLogoAsList {
  $heightOffset = 3
  $widthOffset = 3
  $widthOffsetString = ' ' * $widthOffset

  $logo = Get-LogoAsString
  $heart = Get-HeartAsString

  $logoLines = $logo -split "`n"
  $heartLines = $heart -split ("`n") | Where-Object { $_ -match 'H' }
  $linesToOverwrite = [Math]::Min($logoLines.Length, $heartLines.Length)

  for ($i = 0; $i -lt $linesToOverwrite; $i++) {
    $currentLine = $logoLines[$i + $heightOffset]
    $heartLine = $widthOffsetString + $heartLines[$i]

    $newCurrentLine = $heartLine + $currentLine.Substring($heartLine.Length)
    $logoLines[$i + $heightOffset] = $newCurrentLine
  }

  Return @($logoLines, $heartLines)

}
