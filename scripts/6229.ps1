$UserSessions = query.exe session | Select-Object -Skip 1
foreach ($SessionString in $UserSessions) {
    $Session = $SessionString.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries) 
    if (($Session[2] -eq "Disc") -and ($Session[0] -ne "services")) {
        logoff.exe $Session[1] /V
    }
}
