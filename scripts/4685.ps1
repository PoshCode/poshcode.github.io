$url = "http://www.somepage.com/"
$interval = 60
$shell = New-Object -ComObject Shell.Application

"Refreshing $url every $interval seconds."
"Press ctrl+c to stop."

while(1){
    if (($shell.Windows() | where LocationURL -eq $url) -eq $null) { start $url }
    ($shell.Windows() | where LocationURL -eq $url).Refresh()
    sleep $interval
}
