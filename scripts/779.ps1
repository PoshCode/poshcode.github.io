function ISE-CopyOutPutToEditor () {
    $count = $psise.CurrentOpenedRunspace.OpenedFiles.count
    $psIse.CurrentOpenedRunspace.OpenedFiles.Add()
    $Newfile = $psIse.CurrentOpenedRunspace.OpenedFiles[$count]
    $Newfile.Editor.Text = $psIse.CurrentOpenedRunspace.output.Text
    $Newfile.Editor.Focus()
    # $psise.CurrentOpenedFile.editor.Text = $psIse.CurrentOpenedRunspace.output.Text
}
$null = $psIse.CustomMenu.Submenus.Add("Copy Output to Editor", {ISE-CopyOutPutToEditor}, 'Ctrl+O')

