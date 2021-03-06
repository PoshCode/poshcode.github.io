#requires -version 2.0
## ISE-Lines module v 1.2
##############################################################################################################
## Provides Line cmdlets for working with ISE
## Duplicate-Line - Duplicates current line
## Conflate-Line - Conflates current and next line
## MoveUp-Line - Moves current line up
## MoveDown-Line - Moves current line down
## Delete-TrailingBlanks - Deletes trailing blanks in the whole script
##
## Usage within ISE or Microsoft.PowershellISE_profile.ps1:
## Import-Module ISE-Lines.psm1
##
##############################################################################################################
## History:
## 1.2 - Minor alterations to work with PowerShell 2.0 RTM and Documentation updates (Hardwick)
##       Include Delete-BlankLines function (author Kriszio I believe)
## 1.1 - Bugfix and remove line continuation character while joining for Conflate-Line function (Kriszio)
## 1.0 - Initial release (Poetter)
##############################################################################################################

## Duplicate-Line
##############################################################################################################
## Duplicates current line
##############################################################################################################
function Duplicate-Line
{
    $editor = $psISE.CurrentFile.Editor
    $caretLine = $editor.CaretLine
    $caretColumn = $editor.CaretColumn
    $text = $editor.Text.Split("`n")
    $line = $text[$caretLine -1]
    $newText = $text[0..($caretLine -1)]
    $newText += $line
    $newText += $text[$caretLine..($text.Count -1)]
    $editor.Text = [String]::Join("`n", $newText)
    $editor.SetCaretPosition($caretLine, $caretColumn)
}

## Conflate-Line
##############################################################################################################
## Conflates current and next line
## v 1.1 fixed bug on last but one line and remove line continuation character while joining
##############################################################################################################
function Conflate-Line
{
    $editor = $psISE.CurrentFile.Editor
    $caretLine = $editor.CaretLine
    $caretColumn = $editor.CaretColumn
    $text = $editor.Text.Split("`n")
    if ( $caretLine -ne $text.Count )
    {
        $line = $text[$caretLine -1] + $text[$caretLine] -replace ("(``)?`r", "")
        $newText = @()
        if ( $caretLine -gt 1 )
        {
            $newText = $text[0..($caretLine -2)]
        }
        $newText += $line
        if ( $caretLine -ne $text.Count - 1)
        {
            $newText += $text[($caretLine +1)..($text.Count -1)]
        }
        $editor.Text = [String]::Join("`n", $newText)
        $editor.SetCaretPosition($caretLine, $caretColumn)
    }
}

## MoveUp-Line
##############################################################################################################
## Moves current line up
##############################################################################################################
function MoveUp-Line
{
    $editor = $psISE.CurrentFile.Editor
    $caretLine = $editor.CaretLine
    if ( $caretLine -ne 1 )
    {
        $caretColumn = $editor.CaretColumn
        $text = $editor.Text.Split("`n")
        $line = $text[$caretLine -1]
        $lineBefore = $text[$caretLine -2]
        $newText = @()
        if ( $caretLine -gt 2 )
        {
            $newText = $text[0..($caretLine -3)]
        }
        $newText += $line
        $newText += $lineBefore
        if ( $caretLine -ne $text.Count )
        {
            $newText += $text[$caretLine..($text.Count -1)]
        }
        $editor.Text = [String]::Join("`n", $newText)
        $editor.SetCaretPosition($caretLine - 1, $caretColumn)
    }
}

## MoveDown-Line
##############################################################################################################
## Moves current line down
##############################################################################################################
function MoveDown-Line
{
    $editor = $psISE.CurrentFile.Editor
    $caretLine = $editor.CaretLine
    $caretColumn = $editor.CaretColumn
    $text = $editor.Text.Split("`n")
    if ( $caretLine -ne $text.Count )
    {
        $line = $text[$caretLine -1]
        $lineAfter = $text[$caretLine]
        $newText = @()
        if ( $caretLine -ne 1 )
        {
            $newText = $text[0..($caretLine -2)]
        }
        $newText += $lineAfter
        $newText += $line
        if ( $caretLine -lt $text.Count -1 )
        {
            $newText += $text[($caretLine +1)..($text.Count -1)]
        }
        $editor.Text = [String]::Join("`n", $newText)
        $editor.SetCaretPosition($caretLine +1, $caretColumn)
    }
}

## Delete-TrailingBlanks
##############################################################################################################
## Deletes trailing blanks in the whole script
##############################################################################################################
function Delete-TrailingBlanks
{
    $editor = $psISE.CurrentFile.Editor
    $caretLine = $editor.CaretLine
    $newText = @()
    foreach ( $line in $editor.Text.Split("`n") )
    {
        $newText += $line -replace ("\s+$", "")
    }
    $editor.Text = [String]::Join("`n", $newText)
    $editor.SetCaretPosition($caretLine, 1)
}

## Delete-BlankLines
##############################################################################################################
## Deletes blank lines from the selected text
##############################################################################################################
function Delete-BlankLines
{
# Code from the ISECream Archive (http://psisecream.codeplex.com/), originally named Remove-IseEmptyLines

    # Todo it would be nice to keep the caretposition, but I found no easy way
    # of course you can split the string into an array of lines
    $editor = $psISE.CurrentFile.Editor
    #$caretLine = $editor.CaretLine
    if ($editor.SelectedText)
    {
        Write-Host 'selected'
        $editor.InsertText(($editor.SelectedText -replace '(?m)\s*$', ''))
    }
    else
    {
        $editor.Text = $editor.Text -replace '(?m)\s*$', ''
    }
    $editor.SetCaretPosition(1, 1)
}


##############################################################################################################
## Inserts a submenu Lines to ISE's Custum Menu
## Inserts command Duplicate Line to submenu Lines
## Inserts command Conflate Line Selected to submenu Lines
## Inserts command Move Up Line to submenu Lines
## Inserts command Move Down Line to submenu Lines
## Inserts command Delete Trailing Blanks to submenu Lines
## Inserts command Delete Blank Lines to submenu Lines
##############################################################################################################
if (-not( $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus | where { $_.DisplayName -eq "Lines" } ) )
{
	$linesMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("_Lines",$null,$null) 
	$null = $linesMenu.Submenus.Add("Duplicate Line", {Duplicate-Line}, "Ctrl+Alt+D")
	$null = $linesMenu.Submenus.Add("Conflate Line", {Conflate-Line}, "Ctrl+Alt+J")
	$null = $linesMenu.Submenus.Add("Move Up Line", {MoveUp-Line}, "Ctrl+Shift+Up")
	$null = $linesMenu.Submenus.Add("Move Down Line", {MoveDown-Line}, "Ctrl+Shift+Down")
	$null = $linesMenu.Submenus.Add("Delete Trailing Blanks", {Delete-TrailingBlanks}, "Ctrl+Shift+Del")
	$null = $linesMenu.Submenus.Add("Delete Blank Lines", {Delete-BlankLines}, "Ctrl+Shift+End")
}

# If you are using IsePack (http://code.msdn.microsoft.com/PowerShellPack) and IseCream (http://psisecream.codeplex.com/),
# you can use this code to add your menu items. The added benefits are that you can specify the order of the menu items and
# if the shortcut already exists it will add the menu item without the shortcut instead of failing as the default does.
# Add-IseMenu -Name "Lines" @{            
#    "Duplicate Line"  = {Duplicate-Line}| Add-Member NoteProperty order  1 -PassThru | Add-Member NoteProperty ShortcutKey "Ctrl+Alt+D" -PassThru
#    "Conflate Line" = {Conflate-Line}| Add-Member NoteProperty order  2 -PassThru | Add-Member NoteProperty ShortcutKey "Ctrl+Alt+J" -PassThru
#    "Move Up Line" = {MoveUp-Line}| Add-Member NoteProperty order  3 -PassThru | Add-Member NoteProperty ShortcutKey "Ctrl+Shift+Up" -PassThru
#    "Move Down Line"   = {MoveDown-Line}| Add-Member NoteProperty order  4 -PassThru | Add-Member NoteProperty ShortcutKey "Ctrl+Shift+Down" -PassThru
#    "Delete Trailing Blanks" = {Delete-TrailingBlanks}| Add-Member NoteProperty order  5 -PassThru | Add-Member NoteProperty ShortcutKey "Ctrl+Shift+Del" -PassThru
#    "Delete Blank Lines" = {Delete-BlankLines} | Add-Member NoteProperty order  6 -PassThru | Add-Member NoteProperty ShortcutKey "Ctrl+Shift+End" -PassThru
#    }
    
