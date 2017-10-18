

$ping = new-object System.Net.NetworkInformation.Ping
$isbad = $true;
do {
try {
    $Reply = $ping.send('www.yahoo.com')
    if ($Reply.status –ne “Success”) { $txt = "$(get-date) problem"  ; write-Host $txt ; $txt | out-File -append c:\downloads\jetstreamlog.txt} 
    else { 
        if ($isbad) {$isbad = $false;$txt = "$(get-date) RECOVERED";write-Host $txt ; $txt | out-File -append c:\downloads\jetstreamlog.txt  }
        $txt = "$(get-date) good" ;write-Host $txt }
    }
catch {
    $isbad = $true;
    $txt = "$(get-date) EXCEPTION"  ; write-Host $txt ; $txt | out-File -append c:\downloads\jetstreamlog.txt
}
sleep 4
}
while ($true)



 
