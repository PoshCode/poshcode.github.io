function Get-Cpl {
dir $env:windir\system32 | Where-Object {$_.Extension -eq ".cpl"} | Select-Object Name,@{Name="Description";Expression={$_.VersionInfo.FileDescription}} | Sort-Object Description | Format-Table -AutoSize
}
