#requires -version 2.0
## ISE-Lines module v 1.0
## DEVELOPED FOR CTP3 
## See comments for each function for changes ...
##############################################################################################################
## Provides Line cmdlets for working with ISE
## Duplicate-Line - Duplicates current line
## Conflate-Line - Conflates current and next line
## MoveUp-Line - Moves current line up
## MoveDown-Line - Moves current line down
## Delete-TrailingBlanks - Deletes trailing blanks in the whole script
##############################################################################################################

## Duplicate-Line
##############################################################################################################
## Duplicates current line
##############################################################################################################
function Duplicate-Line
{
    $editor = $psISE.CurrentOpenedFile.Editor
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
##############################################################################################################
function Conflate-Line
{
    $editor = $psISE.CurrentOpenedFile.Editor
    $caretLine = $editor.CaretLine
    $caretColumn = $editor.CaretColumn
    $text = $editor.Text.Split("`n")
    if ( $caretLine -ne $text.Count )
    {
        $line = $text[$caretLine -1] + $text[$caretLine] -replace ("`r", "")
        $newText = @()
        if ( $caretLine -gt 1 )
        {
            $newText = $text[0..($caretLine -2)]
        }
        $newText += $line
        $newText += $text[($caretLine +1)..($text.Count -1)]
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
    $editor = $psISE.CurrentOpenedFile.Editor
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
    $editor = $psISE.CurrentOpenedFile.Editor
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
    $editor = $psISE.CurrentOpenedFile.Editor
    $caretLine = $editor.CaretLine
    $newText = @()
    foreach ( $line in $editor.Text.Split("`n") )
    {
        $newText += $line -replace ("\s+$", "")
    }
    $editor.Text = [String]::Join("`n", $newText)
    $editor.SetCaretPosition($caretLine, 1)
}

##############################################################################################################
## Inserts a submenu Lines to ISE's Custum Menu
## Inserts command Duplicate Line to submenu Lines
## Inserts command Conflate Line Selected to submenu Lines
## Inserts command Move Up Line to submenu Lines
## Inserts command Move Down Line to submenu Lines
## Inserts command Delete Trailing Blanks to submenu Lines
##############################################################################################################
if (-not( $psISE.CustomMenu.Submenus | where { $_.DisplayName -eq "Line" } ) )
{
    $lineMenu = $psISE.CustomMenu.Submenus.Add("_Lines", $null, $null)
    $null = $lineMenu.Submenus.Add("Duplicate Line", {Duplicate-Line}, "Ctrl+Alt+D")
    $null = $lineMenu.Submenus.Add("Conflate Line", {Conflate-Line}, "Ctrl+Alt+J")
    $null = $lineMenu.Submenus.Add("Move Up Line", {MoveUp-Line}, "Ctrl+Shift+Up")
    $null = $lineMenu.Submenus.Add("Move Down Line", {MoveDown-Line}, "Ctrl+Shift+Down")
    $null = $lineMenu.Submenus.Add("Delete Trailing Blanks", {Delete-TrailingBlanks}, "Ctrl+Shift+Del")
}
