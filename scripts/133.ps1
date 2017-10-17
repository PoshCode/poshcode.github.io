Param($srv=$env:ComputerName)
$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Srv)
$key = $regKey.OpenSubkey("SYSTEM\CurrentControlSet\Control\Session Manager\Environment",$false)
$key.GetValueNames() | Select-Object @{n="ValueName";e={$_}},@{n="Value";e={$key.GetValue($_)}}
