$hdr_txt = gc ./hdr.txt

$rec_hdr_regex = [regex]"^Received\:\sfrom\s(.+?)\sby\s(.+?)\;\s(.+?\d\d\:\d\d\:\d\d\s[+|-]\d{4})"


$from_hdr = $hdr_txt | select-string "^From\:\s.+$"
$rec_block = $hdr_txt[0..$($from_hdr.linenumber -2)]
$rec_lines = $rec_block | select-string "^Received\:\sfrom"
$sent_hdr = $hdr_txt | select-string "^Date\:\s.+$"
$sent_hdr.line -match "^Date\:\s(.+)$" > $nul
$sent_ts = [datetime]$matches[1]

foreach ($rec_line in $rec_lines[1..$($rec_lines.count -1)]){$rec_block[$rec_line.linenumber -1] = "~" + $rec_line.line}
$rec_hdrs  = $([string]$rec_block).split("~")


Write-host "`nMessage sent $($sent_ts)`n"

$i = $rec_hdrs.count -1
$last_ts = $sent_ts

while ($i -ge 0) {
$rec_hdrs[$i] -match $rec_hdr_regex > $nul
$rec_ts = [datetime]$matches[3] 
$latency = $rec_ts - $last_ts
$last_ts = $rec_ts
write-host "latency is $($latency.totalseconds) seconds`n"
write-host $matches[1]   
$i--
}

Write-host "`nMessage received $($last_ts)"
write-host "Total time is $($($last_ts - $sent_ts).seconds) seconds.`n"

