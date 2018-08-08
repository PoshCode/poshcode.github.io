#requires -version 2.0
## ISE-Comments module v 1.0
## DEVELOPED FOR CTP3 
## See comments for each function for changes ...
##############################################################################################################
## Provides Comment cmdlets for working with ISE
## ConvertTo-BlockComment - Comments out selected text with <# before and #> after
## ConvertTo-BlockUncomment - Removes <# before and #> after selected text
## ConvertTo-Comment - Comments out selected text with a leeding # on every line 
## ConvertTo-Uncomment - Removes leeding # on every line of selected text
##############################################################################################################

## ConvertTo-BlockComment
##############################################################################################################
## Comments out selected text with <# before and #> after
## This code was originaly designed by Jeffrey Snover and was taken from the Windows PowerShell Blog.
## The original function was named ConvertTo-Comment but as it comments out a block I renamed it.
##############################################################################################################
function ConvertTo-BlockComment
{
    $editor = $psISE.CurrentOpenedFile.Editor
    $CommentedText = "<#`n" + $editor.SelectedText + "#>"
    # INSERTING overwrites the SELECTED text
    $editor.InsertText($CommentedText)
}

## ConvertTo-BlockUncomment
##############################################################################################################
## Removes <# before and #> after selected text
##############################################################################################################
function ConvertTo-BlockUncomment
{
    $editor = $psISE.CurrentOpenedFile.Editor
    $CommentedText = $editor.SelectedText -replace ("^<#`n", "")
    $CommentedText = $CommentedText -replace ("#>$", "")
    # INSERTING overwrites the SELECTED text
    $editor.InsertText($CommentedText)
}

## ConvertTo-Comment
##############################################################################################################
## Comments out selected text with a leeding # on every line
##############################################################################################################
function ConvertTo-Comment
{
    $editor = $psISE.CurrentOpenedFile.Editor
    $CommentedText = $editor.SelectedText.Split("`n")
    # INSERTING overwrites the SELECTED text
    $editor.InsertText( "#" + ( [String]::Join("`n#", $CommentedText)))
}

## ConvertTo-Uncomment
##############################################################################################################
## Comments out selected text with <# before and #> after
##############################################################################################################
function ConvertTo-Uncomment
{
    $editor = $psISE.CurrentOpenedFile.Editor
    $CommentedText = $editor.SelectedText.Split("`n") -replace ( "^#", "" )
    # INSERTING overwrites the SELECTED text
    $editor.InsertText( [String]::Join("`n", $CommentedText))
}

##############################################################################################################
## Inserts a submenu Comments to ISE's Custum Menu
## Inserts command Block Comment Selected to submenu Comments
## Inserts command Block Uncomment Selected to submenu Comments
## Inserts command Comment Selected to submenu Comments
## Inserts command Uncomment Selected to submenu Comments
##############################################################################################################
if (-not( $psISE.CustomMenu.Submenus | where { $_.DisplayName -eq "Comments" } ) )
{
    $commentsMenu = $psISE.CustomMenu.Submenus.Add("_Comments", $null, $null)
    $null = $commentsMenu.Submenus.Add("Block Comment Selected", {ConvertTo-BlockComment}, "Ctrl+SHIFT+B")
    $null = $commentsMenu.Submenus.Add("Block Uncomment Selected", {ConvertTo-BlockUncomment}, "Ctrl+Alt+B")
    $null = $commentsMenu.Submenus.Add("Comment Selected", {ConvertTo-Comment}, "Ctrl+SHIFT+C")
    $null = $commentsMenu.Submenus.Add("Uncomment Selected", {ConvertTo-Uncomment}, "Ctrl+Alt+C")
}
