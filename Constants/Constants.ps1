# Suppress 'unused-variable'-warning for this file
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()


# Git-related constants
$global:FIFTY_CHARS = '|--------1---------2---------3---------4---------|'


# Classes
class NavigableMenuElement { [char]$trigger; [string]$label; [scriptblock]$action; }
