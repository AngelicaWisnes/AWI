
###########################
# Pride-related functions #
###########################
function Get-RainbowLine { Get-FlagLine -colorScheme:'rainbow' }
function Get-TransLine { Get-FlagLine -colorScheme:'trans' }
function Get-BisexualLine { Get-FlagLine -colorScheme:'bisexual' }
function Get-NonbinaryLine { Get-FlagLine -colorScheme:'nonbinary' }
function Get-NorwayLine { Get-FlagLine -colorScheme:'norway' }

function Get-FlagLine {
  param( [Parameter(Mandatory)][String]$colorScheme )
  $windowWidth, $_ = Get-WindowDimensions
  $spaceLength = (' ' * $windowWidth)
  Write-Host
  $Global:RGBChart[$colorScheme].fg | ForEach-Object { Write-Host ('{0}{1}' -f $_.bg, $spaceLength) }
}


function Get-RainbowSlimLine {
  param( [switch]$NoNewlineStart = $False )
  Get-SlimFlagLine -colorScheme:'rainbow' -NoNewlineStart:$NoNewlineStart
}


function Get-TransSlimLine {
  param( [switch]$NoNewlineStart = $False )
  Get-SlimFlagLine -colorScheme:'trans' -NoNewlineStart:$NoNewlineStart
}


function Get-SlimFlagLine {
  param( [switch]$NoNewlineStart = $False, [String]$colorScheme = 'trans' )
  
  $colors = $Global:RGBChart[$colorScheme].fg
  $numberOfColors = $colors.Count
  $windowWidth, $_ = Get-WindowDimensions -widthPadding:0

  $spaceLength = [math]::floor($windowWidth / $numberOfColors)
  $spaces = ' ' * $spaceLength
  $restSpaceLength = $windowWidth - ($spaceLength * $numberOfColors)
  $restSpaces = $spaces + (' ' * $restSpaceLength)

  If (-not $NoNewlineStart) { Write-Host }
  For ($i = 0; $i -lt $numberOfColors; $i++) {
    Write-Host ('{0}{1}' -f $colors[$i].bg, $(If ($i -eq $numberOfColors - 1) { $restSpaces } Else { $spaces })) -NoNewline:$($i -lt $numberOfColors - 1)
  }
}


function Get-RainbowSlimShortLine {
  $spaceLength = '   '
  $Global:RGBChart['rainbow'].fg | ForEach-Object { Write-Host ('{0}{1}' -f $_.bg, $spaceLength) -NoNewline }
}


function Get-PrideSmall {
  Write-Host ('
  {0}{1}{2}#{3}###{4}###{5}####################################{11}
  {0}{1}{2}##{3}###{4}###{5}###################################{11}
  {0}{1}#{2}###{3}###{4}###{6}#################################{11}
  {0}{1}##{2}###{3}###{4}###{6}################################{11}
  {0}#{1}###{2}###{3}###{4}###{7}##############################{11}
  {0}##{1}###{2}###{3}###{4}###{7}#############################{11}
  {0}##{1}###{2}###{3}###{4}###{8}#############################{11}
  {0}#{1}###{2}###{3}###{4}###{8}##############################{11}
  {0}{1}##{2}###{3}###{4}###{9}################################{11}
  {0}{1}#{2}###{3}###{4}###{9}#################################{11}
  {0}{1}{2}##{3}###{4}###{10}###################################{11}
  {0}{1}{2}#{3}###{4}###{10}####################################
  ' -f $Global:RGBs.PrideWhite.fg, $Global:RGBs.PridePink.fg, $Global:RGBs.PrideCyan.fg, $Global:RGBs.PrideBrown.fg, $Global:RGBs.PrideBlack.fg, 
    $Global:RGBs.PrideRed.fg, $Global:RGBs.PrideOrange.fg, $Global:RGBs.PrideYellow.fg, 
    $Global:RGBs.PrideGreen.fg, $Global:RGBs.PrideBlue.fg, $Global:RGBs.PridePurple.fg, $Global:RGB_RESET)
}


function Get-PrideMedium {
  Write-Host ('
  {0}{1}{2}#{3}###{4}###{5}#############################################################################{11}
  {0}{1}{2}##{3}###{4}###{5}############################################################################{11}
  {0}{1}{2}###{3}###{4}###{5}###########################################################################{11}
  {0}{1}#{2}###{3}###{4}###{5}##########################################################################{11}
  {0}{1}##{2}###{3}###{4}###{6}#########################################################################{11}
  {0}{1}###{2}###{3}###{4}###{6}########################################################################{11}
  {0}#{1}###{2}###{3}###{4}###{6}#######################################################################{11}
  {0}##{1}###{2}###{3}###{4}###{6}######################################################################{11}
  {0}###{1}###{2}###{3}###{4}###{7}#####################################################################{11}
  {0}####{1}###{2}###{3}###{4}###{7}####################################################################{11}
  {0}#####{1}###{2}###{3}###{4}###{7}###################################################################{11}
  {0}######{1}###{2}###{3}###{4}###{7}##################################################################{11}
  {0}######{1}###{2}###{3}###{4}###{8}##################################################################{11}
  {0}#####{1}###{2}###{3}###{4}###{8}###################################################################{11}
  {0}####{1}###{2}###{3}###{4}###{8}####################################################################{11}
  {0}###{1}###{2}###{3}###{4}###{8}#####################################################################{11}
  {0}##{1}###{2}###{3}###{4}###{9}######################################################################{11}
  {0}#{1}###{2}###{3}###{4}###{9}#######################################################################{11}
  {0}{1}###{2}###{3}###{4}###{9}########################################################################{11}
  {0}{1}##{2}###{3}###{4}###{9}#########################################################################{11}
  {0}{1}#{2}###{3}###{4}###{10}##########################################################################{11}
  {0}{1}{2}###{3}###{4}###{10}###########################################################################{11}
  {0}{1}{2}##{3}###{4}###{10}############################################################################{11}
  {0}{1}{2}#{3}###{4}###{10}#############################################################################
  ' -f $Global:RGBs.PrideWhite.fg, $Global:RGBs.PridePink.fg, $Global:RGBs.PrideCyan.fg, $Global:RGBs.PrideBrown.fg, $Global:RGBs.PrideBlack.fg, 
    $Global:RGBs.PrideRed.fg, $Global:RGBs.PrideOrange.fg, $Global:RGBs.PrideYellow.fg, 
    $Global:RGBs.PrideGreen.fg, $Global:RGBs.PrideBlue.fg, $Global:RGBs.PridePurple.fg, $Global:RGB_RESET)
}


function Get-PrideLarge {
  Write-Host ('
  {0}{1}{2}#{3}###{4}###{5}########################################################################################{11}
  {0}{1}{2}###{3}###{4}###{5}######################################################################################{11}
  {0}{1}##{2}###{3}###{4}###{5}####################################################################################{11}
  {0}#{1}###{2}###{3}###{4}###{5}##################################################################################{11}
  {0}###{1}###{2}###{3}###{4}###{6}################################################################################{11}
  {0}#####{1}###{2}###{3}###{4}###{6}##############################################################################{11}
  {0}#######{1}###{2}###{3}###{4}###{6}############################################################################{11}
  {0}#########{1}###{2}###{3}###{4}###{6}##########################################################################{11}
  {0}###########{1}###{2}###{3}###{4}###{7}########################################################################{11}
  {0}#############{1}###{2}###{3}###{4}###{7}######################################################################{11}
  {0}###############{1}###{2}###{3}###{4}###{7}####################################################################{11}
  {0}#################{1}###{2}###{3}###{4}###{7}##################################################################{11}
  {0}#################{1}###{2}###{3}###{4}###{8}##################################################################{11}
  {0}###############{1}###{2}###{3}###{4}###{8}####################################################################{11}
  {0}#############{1}###{2}###{3}###{4}###{8}######################################################################{11}
  {0}###########{1}###{2}###{3}###{4}###{8}########################################################################{11}
  {0}#########{1}###{2}###{3}###{4}###{9}##########################################################################{11}
  {0}#######{1}###{2}###{3}###{4}###{9}############################################################################{11}
  {0}#####{1}###{2}###{3}###{4}###{9}##############################################################################{11}
  {0}###{1}###{2}###{3}###{4}###{9}################################################################################{11}
  {0}#{1}###{2}###{3}###{4}###{10}##################################################################################{11}
  {0}{1}##{2}###{3}###{4}###{10}####################################################################################{11}
  {0}{1}{2}###{3}###{4}###{10}######################################################################################{11}
  {0}{1}{2}#{3}###{4}###{10}########################################################################################
  ' -f $Global:RGBs.PrideWhite.fg, $Global:RGBs.PridePink.fg, $Global:RGBs.PrideCyan.fg, $Global:RGBs.PrideBrown.fg, $Global:RGBs.PrideBlack.fg, 
    $Global:RGBs.PrideRed.fg, $Global:RGBs.PrideOrange.fg, $Global:RGBs.PrideYellow.fg, 
    $Global:RGBs.PrideGreen.fg, $Global:RGBs.PrideBlue.fg, $Global:RGBs.PridePurple.fg, $Global:RGB_RESET)
}


function Get-PrideLogo {
  Write-Host ('
  {0}{1}{2}#{3}###{4}###{5}##########################################################################################################################{11}
  {0}{1}{2}###{3}###{4}###{5}########################################################################################################################{11}
  {0}{1}##{2}###{3}###{4}###{5}######################################################################################################################{11}
  {0}#{1}###{2}###{3}###{4}###{5}#########################################################################################################       ####{11}
  {0}###{1}###{2}###{3}###{4}###{5}#################################################################################################              ###{11}
  {0}#####{1}###{2}###{3}###{4}###{6}###########################################################################################          ###########{11}
  {0}#######{1}###{2}###{3}###{4}###{6}##################################             ####################    ##############         ################{11}
  {0}#########{1}###{2}###{3}###{4}###{6}############################         ###       ################      ###########        ####################{11}
  {0}###########{1}###{2}###{3}###{4}###{6}#######################       ###########      ############       ##########       #######################{11}
  {0}#############{1}###{2}###{3}###{4}###{6}##################        ##############      #########        #########      ##########################{11}
  {0}###############{1}###{2}###{3}###{4}###{7}###############      #################      #######        ########       ############################{11}
  {0}#################{1}###{2}###{3}###{4}###{7}###########      ###################       ####          ######       ##############################{11}
  {0}###################{1}###{2}###{3}###{4}###{7}########      ####################       ###          #####       ################################{11}
  {0}#####################{1}###{2}###{3}###{4}###{7}#####     #####################        #            ####      ##################################{11}
  {0}#######################{1}###{2}###{3}###{4}###{7}#      ######################       #            ###      ####################################{11}
  {0}#######################{1}###{2}###{3}###{4}###{8}         ###################                    ##      ######################################{11}
  {0}#####################{1}###{2}###{3}###{4}###{8}#              ############                      ##      #######################################{11}
  {0}###################{1}###{2}###{3}###{4}###{8}#       ####                              #              #########################################{11}
  {0}#################{1}###{2}###{3}###{4}###{8}#        ########            ##            #             ###########################################{11}
  {0}###############{1}###{2}###{3}###{4}###{8}##        ######################           ##             ############################################{11}
  {0}#############{1}###{2}###{3}###{4}###{9}##         ######################          ####           ##############################################{11}
  {0}####     ##{1}###{2}###{3}###{4}###{9}##         #######################          ####          ################################################{11}
  {0}####     {1} ##{2}###{3}###{4}###{9}##         ########################         #####         ##################################################{11}
  {0}####   {1}  #{2}###{3}###{4}###{9}##         #########################        ######         ###################################################{11}
  {0}#####{1}   {2}   {3}###{4}## {9}          ##########################        #######        #####################################################{11}
  {0}###{1}###{2}#  {3}   {4}   {10}       ##############################       ########      ########################################################{11}
  {0}#{1}###{2}###{3}###{4}###{10}######################################     #########      ##########################################################{11}
  {0}{1}##{2}###{3}###{4}###{10}######################################################################################################################{11}
  {0}{1}{2}###{3}###{4}###{10}########################################################################################################################{11}
  {0}{1}{2}#{3}###{4}###{10}##########################################################################################################################
' -f $Global:RGBs.PrideWhite.fg, $Global:RGBs.PridePink.fg, $Global:RGBs.PrideCyan.fg, $Global:RGBs.PrideBrown.fg, $Global:RGBs.PrideBlack.fg, 
    $Global:RGBs.PrideRed.fg, $Global:RGBs.PrideOrange.fg, $Global:RGBs.PrideYellow.fg, 
    $Global:RGBs.PrideGreen.fg, $Global:RGBs.PrideBlue.fg, $Global:RGBs.PridePurple.fg, $Global:RGB_RESET)
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
