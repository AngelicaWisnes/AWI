
########################################
# Functions specific for this computer #
########################################


# No system dependent functions are implemented yet
Add-ToFunctionList -category "System" -Name "N/A" -Value "N/A"



########################################
# Functions for use in general scripts #
########################################


function SystemDependentGitCheckouts { 
  OUT $(PE -txt:"No system dependent git checkouts are implemented" -fg:$global:colors.Cyan)
}
  