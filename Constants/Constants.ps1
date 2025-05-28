# Suppress 'unused-variable'-warning for this file
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')] param()

# Character constants
$Global:upArrow = [char]0x2191     # ↑
$Global:downArrow = [char]0x2193   # ↓
$Global:leftArrow = [char]0x2190   # ←
$Global:rightArrow = [char]0x2192  # →
$Global:checkMark = [char]0x2714   # ✔
$Global:warningSign = [char]0x26A0 # ⚠

# Git-related constants
$Global:FIFTY_CHARS = '|--------1---------2---------3---------4---------|'


# Global Classes
class NavigableMenuElement { [char]$trigger; [string]$label; [scriptblock]$action; }
