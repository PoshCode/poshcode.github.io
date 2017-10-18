# validate given IP address in $ip1 variable
$ip1=read-host "Enter any IP Address"
($ip1.split(".") | where-object { ([int]$_) -ge 1 -and ([int]$_) -le 255 } | Where-Object { $_ -match "\d{1,3}"} | Measure-Object).count -eq 4
