Invoke-SqlBackup -sqlserver "WIN7\Kilimanjaro" -dbname "AdventureWorks" `
-filepath "C:\Temp\AdventureWorks_db_$(((Get-Date).ToString("yyyyMMddHHmm"))).bak" 
