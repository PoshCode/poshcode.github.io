# ----------------------------------------------------------------------------- 
# Script: dhcp_bkp.ps1 
# Version: 1.0
# Author: http://blog.teksoporte.es
# Date: 07/29/2015 09:50:31
# Keywords: dhcp backup powershll script
# Comments: This script will compress DHCP server configuration files and copy
# to the specified folder on another ocmputer.
# 
# ----------------------------------------------------------------------------- 
if (-not (test-path "$env:ProgramFiles\DHCP_Backup_Script\7z.exe")) {throw "$env:ProgramFiles\DHCP_Backup_Script\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\DHCP_Backup_Script\7z.exe"

$filesToBkp = "$env:windir\System32\dhcp\Backup\*"  # Don't change!
$zipDest = "\\<Destination_Servers_Path>\DHCP Backups\"  #Here you specify where you want to save the compressed ZIP file
$zipFilename = "$zipdest $env:computername-$(get-date -f dd-MM-yyyy-HH-mm-ss).zip" # Don't change!
$zipLimit = (Get-Date).AddDays(-1)
sz a -Y -tzip $zipFilename $filesToBkp -SSW

Get-ChildItem $zipDest -Recurse | ? {
  -not $_.PSIsContainer -and $_.CreationTime -lt $zipLimit
} | Remove-Item -Force
