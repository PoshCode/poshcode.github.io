function check-ping {
$erroractionpreference = "SilentlyContinue"
$ping = new-object System.Net.NetworkInformation.Ping
$rslt = $ping.send($args)
if ($rslt.status.tostring() –eq “Success”) {
        write-host $args + “ ping worked”
}
else {
        write-host $args + “ ping failed”
}
$ping = $null
}
