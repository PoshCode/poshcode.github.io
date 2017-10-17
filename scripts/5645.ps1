$Migrations = get-moverequest

foreach ($migration in $migrations) {Get-MoveRequestStatistics $migration.alias -IncludeReport | select displayname,status,starttimestamp,completiontimestamp,overallduration,totalmailboxsize,totalmailboxitemcount} | export-csv -Delimiter ';' -NoTypeInformation -Force -Path 'C:\Users\Tester\Desktop\Migrationstats.csv'
