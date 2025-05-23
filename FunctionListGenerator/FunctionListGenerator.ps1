# Suppress 'unused-variable'-warning for this file
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()


########################
# Define function-list #
########################
function ColorizeJade { param([string]$str); Return ('{0}{1}{2}' -f $Global:RGBs.Jade.fg, $str, $Global:RGB_RESET) }
class FunctionListElement { [string]$category ; [string]$name ; [string]$value ; [string]$fillerChar }

$ListElement_Top = [FunctionListElement]@{ category = ''; name = ''; value = ''; fillerChar = '¯' }
$ListElement_BREAK = [FunctionListElement]@{ category = ''; name = ''; value = ''; fillerChar = '-' }
$ListElement_Labels = [FunctionListElement]@{ category = 'CATEGORY'; name = 'NAME'; value = 'VALUE'; fillerChar = ' ' }
$ListElement_Empty = [FunctionListElement]@{ category = ''; name = ''; value = ''; fillerChar = ' ' }
$ListElement_End = [FunctionListElement]@{ category = ''; name = ''; value = ''; fillerChar = '_' }

$global:FunctionLists = @{
  Git        = [System.Collections.Generic.List[FunctionListElement]]::new()
  Jupyter    = [System.Collections.Generic.List[FunctionListElement]]::new()
  PowerShell = [System.Collections.Generic.List[FunctionListElement]]::new()
  Printing   = [System.Collections.Generic.List[FunctionListElement]]::new()
  Program    = [System.Collections.Generic.List[FunctionListElement]]::new()
  Project    = [System.Collections.Generic.List[FunctionListElement]]::new()
  React      = [System.Collections.Generic.List[FunctionListElement]]::new()
  System     = [System.Collections.Generic.List[FunctionListElement]]::new()
  Upgrading  = [System.Collections.Generic.List[FunctionListElement]]::new()
  Setup      = [System.Collections.Generic.List[FunctionListElement]]::new()
  Other      = [System.Collections.Generic.List[FunctionListElement]]::new()
}

foreach ($list in $global:FunctionLists.Values) { $list.Add( $ListElement_BREAK ) }

$SingleList = [System.Collections.Generic.List[FunctionListElement]]::new()
$DualList_Col1 = [System.Collections.Generic.List[FunctionListElement]]::new()
$DualList_Col2 = [System.Collections.Generic.List[FunctionListElement]]::new()


########################################################
# Define helper-functions for function-list-generation #
########################################################
function Add-BlankLinesToDualLists {
  $col1_Len = $DualList_Col2.Count - $DualList_Col1.Count
  $col2_Len = $DualList_Col1.Count - $DualList_Col2.Count

  For ($i = 0; $i -lt $col1_Len; $i++) { $DualList_Col1.Add( $ListElement_Empty ) }
  For ($i = 0; $i -lt $col2_Len; $i++) { $DualList_Col2.Add( $ListElement_Empty ) }
}

function Add-LineToAllLists {
  param([Parameter(Mandatory)][FunctionListElement]$line)
  $SingleList.Add( $line )
  $DualList_Col1.Add( $line )
  $DualList_Col2.Add( $line )
}

function FormatString([string]$str, [int]$colWidth, [string]$fillerChar) {
  $padding = If ($global:isPadded) { (ColorizeJade $fillerChar) }
  $filler = $fillerChar * ($colWidth - $str.Length)
  If ($str.Length -eq 0 ) { $filler = (ColorizeJade $filler) } 
  If (@('CATEGORY', 'NAME', 'VALUE').Contains($str)) { $str = (ColorizeJade $str) }
  Return $padding + $str + $filler + $padding
}

function FormatElement([FunctionListElement]$element) {
  Return '{0}{1}{0}{2}{0}{3}{0}' -f `
  (ColorizeJade '|'),
  (FormatString -str:$element.category -colWidth:$global:categoryWidth -fillerChar:$element.fillerChar),
  (FormatString -str:$element.name -colWidth:$global:nameWidth -fillerChar:$element.fillerChar),
  (FormatString -str:$element.value -colWidth:$global:valueWidth -fillerChar:$element.fillerChar)
}


####################
# Calling-function #
####################
function Initialize-FunctionListGenerator {
  Add-LineToAllLists( $ListElement_Top )
  Add-LineToAllLists( $ListElement_Labels )

  $global:FunctionLists = $global:FunctionLists.GetEnumerator() `
  | Sort-Object { - ($_.Value.Count) } `
  | ForEach-Object { @{ $_.Key = $_.Value } }

  foreach ($subList in $global:FunctionLists.Values) {
    $subList = [System.Collections.Generic.List[FunctionListElement]]($subList | Sort-Object -Property:value)
    $SingleList.AddRange( $subList )

    $diff = $DualList_Col1.Count - $DualList_Col2.Count
    If ($diff -le 0) { $DualList_Col1.AddRange( $subList ) }
    Else { $DualList_Col2.AddRange( $subList ) }
  }

  Add-BlankLinesToDualLists
  Add-LineToAllLists( $ListElement_End )

  $global:categoryWidth = (($SingleList.category) | Measure-Object -Maximum -Property:Length).Maximum
  $global:nameWidth = (($SingleList.name) | Measure-Object -Maximum -Property:Length).Maximum
  $global:valueWidth = (($SingleList.value) | Measure-Object -Maximum -Property:Length).Maximum
}

function Add-ToFunctionList {
  param(
    [Parameter(Mandatory)][String]$category,
    [Parameter(Mandatory)][String]$name,
    [Parameter(Mandatory)][String]$value
  )
  $global:FunctionLists[$category].Add(( [FunctionListElement]@{ category = $category; name = $name; value = $value; fillerChar = ' ' } ))
}

function Get-ListOfFunctionsAndAliases {
  $columnDividers = $outerFrames = $indentSize = 2
  $paddingSize = 6
  $fullInnerWidth = $global:categoryWidth + $global:nameWidth + $global:valueWidth + $columnDividers
  $total_width_single = $fullInnerWidth + $outerFrames + $indentSize + $paddingSize
  $total_width_dual = $total_width_single * 2
  $windowWidth, $_ = Get-WindowDimensions
  $isDual = $total_width_dual -lt $windowWidth
  $global:isPadded = $total_width_single -le $windowWidth

  If (-not $global:isPadded) { $paddingSize = $indentSize = 0 }
  $indent = ' ' * $indentSize

  $sb = [System.Text.StringBuilder]::new("AWI-defined functions and aliases:`n")

  If ($isDual) {
    [void]$sb.AppendLine("$indent{0}$indent{0}" -f $topBar)
    for ($i = 0; $i -lt $DualList_Col1.Count; $i++) {
      [void]$sb.AppendLine("$indent{0}$indent{1}" -f ((FormatElement -element:$DualList_Col1[$i]), (FormatElement -element:$DualList_Col2[$i])))
    }
  }
  Else {
    [void]$sb.AppendLine("$indent{0}" -f $topBar)
    $SingleList | ForEach-Object { [void]$sb.AppendLine("$indent{0}" -f (FormatElement -element:$_)) }
  }

  Write-Host ('{0}{1}' -f $Global:RGBs.DeepPink.fg, $sb.ToString())
}
Set-Alias l Get-ListOfFunctionsAndAliases
Add-ToFunctionList -category 'Other' -name 'l' -value 'Get list of functions and aliases'

function Get-FunctionListInfo {
  Write-Host ("{0}Enter 'l' to list all AWI-defined functions and aliases" -f $Global:RGBs.DeepPink.fg)
}
