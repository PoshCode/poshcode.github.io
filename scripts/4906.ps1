[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
Get-Credential domain\usermname
$Server = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Location of Server List (Ex: 'c:\servers.txt')", "Server List", "$env:ServerList")
$FileLocation = [Microsoft.VisualBasic.Interaction]::InputBox("Enter File Location (Ex: 'C:\tool.exe')", "File Location", "$env:FileLocation")
$FileDestination = [Microsoft.VisualBasic.Interaction]::InputBox("Enter File Destination (Ex: 'windows\system32')", "File Destination", "$env:FileDestination")
Get-Content $Server | foreach {Copy-Item $FileLocation -Destination \\$_\c$\$FileDestination}
