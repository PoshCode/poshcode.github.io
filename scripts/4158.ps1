   #############################################################################################
#
# NAME: SetupVMSQL1.ps1
# AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
# DATE:10/05/2013
#
# COMMENTS: This script will set up the SQL1 VM ready for use and enable SQL Authentication
# Add a user called SQLAdmin with a password of P@ssw0rd
# Restart SQL Service
# ------------------------------------------------------------------------

   
   # Run on SQL1

    # Configure PowerShell Execution Policy to Run all Scripts – It’s a one time Progress
    Set-ExecutionPolicy –ExecutionPolicy Unrestricted

netsh advfirewall firewall add rule name=SQL-SSMS dir=in action=allow enable=yes profile=any
netsh advfirewall firewall add rule name=SQL-SSMS dir=out action=allow program=any enable=yes profile=any
netsh advfirewall firewall set rule group="Remote Administration" new enable=yes
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes
Netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
Netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes
netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
netsh advfirewall firewall set rule group="Windows Firewall Remote Management" new enable =yes
netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable =yes

    # To Load SQL Server Management Objects into PowerShell
    [System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMO’)  | out-null
    [System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMOExtended’)  | out-null
    [System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SqlServer.SqlWmiManagement”) | out-null

SQLPS

$Name = 'SQL1'

Invoke-Sqlcmd -ServerInstance $Name -Database master -Query "USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
GO
"


Invoke-Sqlcmd -ServerInstance $Name  -Database master -Query "USE [master]
GO
CREATE LOGIN [SQLAdmin] WITH PASSWORD=N'P@ssw0rd', DEFAULT_DATABASE=[master]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [SQLAdmin]
GO

"
get-Service -ComputerName $Name  -Name MSSQLSERVER|Restart-Service -force




