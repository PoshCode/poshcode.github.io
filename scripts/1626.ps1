function Delete-TrailingBlanks
{
    $editor = $psISE.CurrentFile.Editor
    $caretLine = $editor.CaretLine

#     First trial. Works.  
#     $newText = @()
#     foreach ( $line in $editor.Text.Split("`n") )
#     {
#         $newText += $line -replace ("\s+$", "")
#     }
#     $editor.Text = [String]::Join("`n", $newText)
 
#    2nd trial, but deletes empty lines too  \s matches `r and `n    
#    $editor.Text = $editor.Text -replace '(?m)\s*$', ''

#    3rd working again, but doesn't it look like perl ? 
#    $editor.Text = $editor.Text -replace  '(?m)[ \t]+(?:\r?)$', ''

#  the solution is so simple  
    $editor.Text = $editor.Text -replace '(?m)\s*?$', ''

       
    $editor.SetCaretPosition($caretLine, 1)
}

