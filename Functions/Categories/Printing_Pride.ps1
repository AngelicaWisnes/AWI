
###########################
# Pride-related functions #
###########################
function Get-RainbowLine { Get-FlagLine -colorScheme:"rainbow" }
function Get-TransLine { Get-FlagLine -colorScheme:"trans" }
function Get-BisexualLine { Get-FlagLine -colorScheme:"bisexual" }
function Get-NonbinaryLine { Get-FlagLine -colorScheme:"nonbinary" }
function Get-NorwayLine { Get-FlagLine -colorScheme:"norway" }

function Get-FlagLine {
  param( [Parameter(Mandatory)][String]$colorScheme )
  $windowWidth, $_ = Get-WindowDimensions
  $spaceLength = (" " * $windowWidth)
  
  $counter = 0
  $global:colorChart[$colorScheme].fg | ForEach-Object { OUT $(PE -txt:$spaceLength -bg:$_) -NoNewlineStart:$($counter++ -ne 0) }
}


function Get-RainbowSlimLine {
  param( [switch]$NoNewlineStart = $False )

  $windowWidth, $_ = Get-WindowDimensions -widthPadding:0
  $spaceLength = [math]::floor($windowWidth / 6)
  $spaces = " " * $spaceLength
  $restSpaceLength = $windowWidth - ($spaceLength * 6)
  $restSpaces = $spaces + (" " * $restSpaceLength)
  
  $colors = $global:colorChart["rainbow"].fg
  $counter = 0
  $colors | ForEach-Object { 
    OUT $(PE -txt:$(If ($counter -eq $colors.Count-1) { $restSpaces } Else { $spaces }) -bg:$_) -NoNewlineStart:($($counter++ -ne 0) -or $NoNewlineStart) -NoNewline 
  }
}


function Get-TransSlimLine {
  param( [switch]$NoNewlineStart = $False )

  $windowWidth, $_ = Get-WindowDimensions -widthPadding:0
  $spaceLength = [math]::floor($windowWidth / 5)
  $spaces = " " * $spaceLength
  $restSpaceLength = $windowWidth - ($spaceLength * 5)
  $restSpaces = $spaces + (" " * $restSpaceLength)
  
  $colors = $global:colorChart["trans"].fg
  $counter = 0
  $colors | ForEach-Object { 
    OUT $(PE -txt:$(If ($counter -eq $colors.Count-1) { $restSpaces } Else { $spaces }) -bg:$_) -NoNewlineStart:($($counter++ -ne 0) -or $NoNewlineStart) -NoNewline 
  }
}


function Get-RainbowSlimShortLine {
  $spaceLength = "   "
  $global:colorChart["rainbow"].fg | ForEach-Object { OUT $(PE -txt:$spaceLength -bg:$_) -NoNewlineStart -NoNewline}
}


function Get-PrideSmall {
  OUT <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"##" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"#" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##############################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"##" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#############################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"##" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#############################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##############################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"#" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"##" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################" -fg:$colors.PridePurple)
}


function Get-PrideMedium { 
  OUT <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#############################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"##" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"############################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###########################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"#" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##########################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#########################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#######################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"##" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"###" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#####################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"####" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"######" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"######" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"####" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"###" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#####################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"##" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#######################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#########################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"#" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##########################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###########################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"##" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"############################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#############################################################################" -fg:$colors.PridePurple)
}


function Get-PrideLarge { 
  OUT <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <##>$(PE -txt:"###" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"################################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##############################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#######" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"############################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#########" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##########################################################################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"###########" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"###############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################################################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"###############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"#############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"###########" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"#########" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##########################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"#######" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"############################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##############################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"###" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"################################################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"####################################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################################" -fg:$colors.PridePurple)
}


function Get-PrideLogo { 
  OUT <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##########################################################################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################################################################" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#########################################################################################################       ####" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <##>$(PE -txt:"###" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#################################################################################################              ###" -fg:$colors.PrideRed), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###########################################################################################          ###########" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#######" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################################             ####################    ##############         ################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#########" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"############################         ###       ################      ###########        ####################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"###########" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#######################       ###########      ############       ##########       #######################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"#############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##################        ##############      #########        #########      ##########################" -fg:$colors.PrideOrange), $(PE -txt:"`n"),
  <##>$(PE -txt:"###############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###############      #################      #######        ########       ############################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"###########      ###################       ####          ######       ##############################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"###################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########      ####################       ###          #####       ################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#####     #####################        #            ####      ##################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#######################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#      ######################       #            ###      ####################################" -fg:$colors.PrideYellow), $(PE -txt:"`n"),
  <##>$(PE -txt:"#######################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"         ###################                    ##      ######################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#              ############                      ##      #######################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"###################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#       ####                              #              #########################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"#################" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"#        ########            ##            #             ###########################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"###############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##        ######################           ##             ############################################" -fg:$colors.PrideGreen), $(PE -txt:"`n"),
  <##>$(PE -txt:"#############" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##         ######################          ####           ##############################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"####     ##" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##         #######################          ####          ################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"####     " -fg:$colors.PrideWhite), $(PE -txt:" ##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##         ########################         #####         ##################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"####   " -fg:$colors.PrideWhite), $(PE -txt:"  #" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##         #########################        ######         ###################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"#####" -fg:$colors.PrideWhite), $(PE -txt:"   " -fg:$colors.PridePink), $(PE -txt:"   " -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"## " -fg:$colors.PrideBlack), $(PE -txt:"          ##########################        #######        #####################################################" -fg:$colors.PrideBlue), $(PE -txt:"`n"),
  <##>$(PE -txt:"###" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"#  " -fg:$colors.PrideCyan), $(PE -txt:"   " -fg:$colors.PrideBrown), $(PE -txt:"   " -fg:$colors.PrideBlack), $(PE -txt:"       ##############################       ########      ########################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <##>$(PE -txt:"#" -fg:$colors.PrideWhite), $(PE -txt:"###" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################     #########      ##########################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite),#> $(PE -txt:"##" -fg:$colors.PridePink), $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"######################################################################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"###" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"########################################################################################################################" -fg:$colors.PridePurple), $(PE -txt:"`n"),
  <#$(PE -txt:"" -fg:$colors.PrideWhite), $(PE -txt:"" -fg:$colors.PridePink),#> $(PE -txt:"#" -fg:$colors.PrideCyan), $(PE -txt:"###" -fg:$colors.PrideBrown), $(PE -txt:"###" -fg:$colors.PrideBlack), $(PE -txt:"##########################################################################################################################" -fg:$colors.PridePurple)
}


function Get-PrideCollection {
  Get-RainbowLine
  Get-TransLine
  Get-BisexualLine
  Get-NonbinaryLine
  Get-NorwayLine
  Get-RainbowSlimLine
  Get-TransSlimLine
  Get-RainbowSlimShortLine
  Get-PrideSmall
  Get-PrideMedium
  Get-PrideLarge
  Get-PrideLogo
}
