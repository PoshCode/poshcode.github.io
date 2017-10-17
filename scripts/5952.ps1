# ------------ Install_DHCPBKP_Script.cmd ------------------------------------  
REM Copy script files from deployment starting point
MD "%ProgramFiles%\DHCP_Backup_Script"
COPY /Y "%~dp0\dhcp_bkp.ps1" "%ProgramFiles%\DHCP_Backup_Script\dhcp_bkp.ps1"
COPY /Y "%~dp0\7z.exe" "%ProgramFiles%\DHCP_Backup_Script\7z.exe"
COPY /Y "%~dp0\7z.dll" "%ProgramFiles%\DHCP_Backup_Script\7z.dll"

REM Create Scheduled Task (Compatible with Windows 2003!)
schtasks /Create /TN "DHCP Backup" /TR "\"%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe\" -noprofile -executionpolicy Unrestricted -File \"%ProgramFiles%\DHCP_Backup_Script\dhcp_bkp.ps1\"" /SC weekly /D MON,TUE,WED,THU,FRI /ST 17:00 /F /RU <USERNAME> /RP <PASSWORD>
# ------------ END of Install_DHCPBKP_Script.cmd ------------------------------

# ------------ Uninstall_DHCPBKP_Script.cmd -----------------------------------  
REM Remove script files
RD  /S /Q "%ProgramFiles%\DHCP_Backup_Script"
RD  /S /Q "%ProgramFiles(x86)%\DHCP_Backup_Script"
REM Remove Scheduled Task
schtasks.exe /Delete /TN "DHCP Backup" /F
# ------------ END of Uninstall_DHCPBKP_Script.cmd ----------------------------  


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
