function New-IseFile ($path = 'tmp_default.ps1')
{
    $count   = $psise.CurrentPowerShellTab.Files.count
    $null    = $psIse.CurrentPowerShellTab.Files.Add()
    $Newfile = $psIse.CurrentPowerShellTab.Files[$count]
    $NewFile.SaveAs($path)
    $NewFile.Save([Text.Encoding]::default)
    $Newfile

}

