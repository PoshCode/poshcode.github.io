(Get-Content c:\loltweaks.export.ps1) | ` Where-Object { $_ -match '\S' } | ` Out-File c:\loltweaks.ps1
$filename = "c:\loltweaks.ps1"
$lines = (Get-Content $filename);
$lines | ForEach-Object { $_.Trim(); } | Out-File C:\LoLtweaks.ps1
Set-AuthenticodeSignature C:\LoLtweaks.ps1 @(Get-ChildItem cert:\CurrentUser\My -codesigning)[0] -TimestampServer http://timestamp.comodoca.com/authenticode
