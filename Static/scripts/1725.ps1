function ISE-CopyOutPutToEditor () {
    $count = $psise.CurrentPowerShellTab.Files.count
    $psIse.CurrentPowerShellTab.Files.Add()
    $Newfile = $psIse.CurrentPowerShellTab.Files[$count]
    $Newfile.Editor.Text = $psIse.CurrentPowerShellTab.Output.Text
    $Newfile.Editor.Focus()
}
$null = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("Copy Output to Editor", {ISE-CopyOutPutToEditor}, 'Ctrl+O') 

