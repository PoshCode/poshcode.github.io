

$servers = get-adcomputer -filter {operatingsystem -like "Windows Server*"} -properties lastlogondate | where {$_.lastlogondate -gt (get-date).adddays(-30)}

$sqlservices = foreach ($server in $servers) {
        if (test-connection $server.dnshostname -quiet -count 1 -delay 1) {
            Get-Service -verbose -computername $server.dnshostname -name "MSSQL*"
        } #if test-connection
} #foreach

$sqlinstances = $sqlservices | where {$_.servicename -like "MSSQLServer" -or $_.servicename -like "MSSQL$*"}

$sqlinstances
