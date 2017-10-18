Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'" | ForEach-Object { 
    $_.SetDNSServerSearchOrder(@("208.67.222.222","208.67.220.220"));
}
