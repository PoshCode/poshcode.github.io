$AllValues = @()
$Values = @()

$Migrations = Get-MoveRequest

foreach ($Migration in $Migrations) 
{
    $Values = Get-MoveRequestStatistics $Migration.alias -IncludeReport | Select-Object displayname,status,starttimestamp,completiontimestamp,overallduration,totalmailboxsize,totalmailboxitemcount

    $NewObject = [pscustomobject]@{
        Displayname = $Values.Displayname
        Status = $Values.Status
        StartTimeStamp = $Values.StartTimeStamp
        CompletionTimeStamp = $Values.Completiontimestamp
        OverallDuration = $Values.OverallDuration
        TotalMailboxSize = $Values.TotalMailBoxSize
        TotalMailboxItemCount = $Values.TotalMailboxItemCount
    }
    $Allvalues += $NewObject
}

$AllValues | Export-Csv -Delimiter ';' -NoTypeInformation -Force -Path 'C:\Users\Tester\Desktop\Migrationstats.csv'
