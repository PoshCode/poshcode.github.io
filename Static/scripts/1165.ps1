# validate given IP address in $ip1 variable
$ip1 = "192.168.22.455"
($ip1.split(".") | where-object { $_ -ge 1 -and $_ -le 255 } | Where-Object { $_ -match "\d{1,3}"} | Measure-Object).count -eq 4


