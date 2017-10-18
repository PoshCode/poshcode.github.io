function Write-IseFile($file, $msg)
{
    $Editor = $file.Editor
    $Editor.SetCaretPosition($Editor.LineCount, 1)
    $Editor.InsertText(($msg  + "`r`n"))
}

