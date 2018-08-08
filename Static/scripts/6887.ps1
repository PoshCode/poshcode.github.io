Clear
$start = Read-Host "Start date (mmddyyyy)"
    $startY = $start.Substring(4,4)
    $startM = $start.Substring(0,2)
    $startD = $start.Substring(2,2)
    $startDate = $startY+"-"+$startM+"-"+$startD
$end = Read-Host "  End date (mmddyyyy)"
    $endY = $end.Substring(4,4)
    $endM = $end.Substring(0,2)
    $endD = $end.Substring(2,2)
    $endDate = $endY+"-"+$endM+"-"+$endD

$timespan = [datetime]$endDate - [datetime]$startDate

If($timespan.Days -gt 365) {[string]$yrs1 = $timespan.days/28/13}
    Else { $yr1 = $timespan.Days / 365.25
        $yrs1 = [string]$yr1 }
$yrs2 = $yrs1.split(".")
$Years = $yrs2[0]
$mnth1 = "." + $yrs2[1]
$mnth2 = [math]::Round($mnth1,5)
If($timespan.Days -gt 365) {$mnth3 = $mnth2 * 13}
    Else {$mnth3 = $mnth2 * 12}
$mnth4 = [string]$mnth3
$mnth5 = $mnth4.split(".")
$Months = $mnth5[0]
$days1 = "." + $mnth5[1]
$days2 = [math]::Round($days1,5)
If($timespan.Days -gt 365) {$Days = [math]::Truncate(($days2 * 24) - 1)}
    Else {$Days = [math]::Round($days2 * 30)}

Write-Host $years "years, "$months "months, "$days "days"

