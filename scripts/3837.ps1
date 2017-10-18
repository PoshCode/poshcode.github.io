Get-WmiObject Win32_Share -computerName SERVERNAME | 
Select Name, Caption, Path | Export-csv "c:\temp\SERVERNAME.csv" -NoTypeInformation
