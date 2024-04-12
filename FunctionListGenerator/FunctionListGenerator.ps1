# Suppress 'unused-variable'-warning for this file
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()


########################
# Define function-list #
########################
class FunctionListElement { [string]$category ; [string]$name ; [string]$value } 

$ListElement_BREAK = [FunctionListElement]@{ category = '-'; name = '-'; value = '-' }
$ListElement_Empty = [FunctionListElement]@{ category = ''; name = ''; value = '' }
$ListElement_Labels = [FunctionListElement]@{ category = 'CATEGORY'; name = 'NAME'; value = 'VALUE' }
$ListElement_End = [FunctionListElement]@{ category = '_'; name = '_'; value = '_' }

$global:FunctionLists = @{
  Git        = [System.Collections.Generic.List[FunctionListElement]]::new();
  Jupyter    = [System.Collections.Generic.List[FunctionListElement]]::new();
  PowerShell = [System.Collections.Generic.List[FunctionListElement]]::new();
  Printing   = [System.Collections.Generic.List[FunctionListElement]]::new();
  Program    = [System.Collections.Generic.List[FunctionListElement]]::new();
  Project    = [System.Collections.Generic.List[FunctionListElement]]::new();
  React      = [System.Collections.Generic.List[FunctionListElement]]::new();
  System     = [System.Collections.Generic.List[FunctionListElement]]::new();
  Upgrading  = [System.Collections.Generic.List[FunctionListElement]]::new();
  Other      = [System.Collections.Generic.List[FunctionListElement]]::new();
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

function FormatString([string]$str, [int]$colWidth, [string]$fillerChar) { 
  $padding = If ($global:isPadded) { $fillerChar }
  return $padding + $str.PadRight($colWidth, $fillerChar) + $padding 
}


function FormatElement([FunctionListElement]$element) {
  $fillerChar = If ($element.value -eq "_") { "_" } Elseif ($element.value -eq "-") { "-" } Else { " " }
  
  Return "|{0}|{1}|{2}|" -f `
  (FormatString -str:$element.category -colWidth:$global:categoryWidth -fillerChar:$fillerChar),
  (FormatString -str:$element.name -colWidth:$global:nameWidth -fillerChar:$fillerChar),
  (FormatString -str:$element.value -colWidth:$global:valueWidth -fillerChar:$fillerChar)
}


####################
# Calling-function #
####################
function Initialize-FunctionListGenerator {
  $SingleList.Add( $ListElement_Labels )
  $DualList_Col1.Add( $ListElement_Labels )
  $DualList_Col2.Add( $ListElement_Labels )
  
  $global:FunctionLists = $global:FunctionLists.GetEnumerator() `
  | Sort-Object { - ($_.Value.Count) } `
  | ForEach-Object { @{ $_.Key = $_.Value } }
  
  foreach ($listObject in $global:FunctionLists.Values) { 
    $listObject = [System.Collections.Generic.List[FunctionListElement]]($listObject | Sort-Object -Property:value)
    $SingleList.AddRange( $listObject )
    
    $diff = $DualList_Col1.Count - $DualList_Col2.Count
    if ($diff -le 0) { $DualList_Col1.AddRange( $listObject ) }
    else { $DualList_Col2.AddRange( $listObject ) }
  }
  
  Add-BlankLinesToDualLists
  $SingleList.Add( $ListElement_End )
  $DualList_Col1.Add( $ListElement_End ) 
  $DualList_Col2.Add( $ListElement_End ) 
  
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
  $global:FunctionLists[$category].Add(( [FunctionListElement]@{ category = $category; name = $name; value = $value } ))
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
  $indent = " " * $indentSize
  $topBar = ".{0}." -f ("_" * ($fullInnerWidth + $paddingSize))

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

  OUT $(PE -txt:$sb.ToString() -fg:$global:colors.DeepPink)
}
Set-Alias l Get-ListOfFunctionsAndAliases
Add-ToFunctionList -category 'Other' -name 'l' -value 'Get list of functions and aliases'

function Get-FunctionListInfo {
  OUT $(PE -txt:"Enter 'l' to list all AWI-defined functions and aliases " -fg:$global:colors.DeepPink)
}
