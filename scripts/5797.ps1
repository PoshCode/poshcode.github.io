$LAN = Get-WmiObject Win32_NetworkAdapter -Filter "AdapterType='Ethernet 802.3'" |
        Where-Object { ($_.NetConnectionID -notlike '*Wireless*' -or $_.NetConnectionID -notlike '*WiFi*' -or $_.NetConnectionID -notlike '*Wi-Fi*' ) -and $_.ServiceName -notlike '*NETw*' } |
        ForEach-Object { $_.GetRelated('Win32_NetworkAdapterConfiguration') } | Where-Object {$_.IPEnabled -eq '$True'}
$WLAN = Get-WmiObject Win32_NetworkAdapter -Filter "AdapterType='Ethernet 802.3'" |
        Where-Object { ($_.NetConnectionID -like '*Wireless*' -or $_.NetConnectionID -like '*WiFi*' -or $_.NetConnectionID -like '*Wi-Fi*' -or $_.ServiceName -like '*NETw*') } |
        ForEach-Object { $_.GetRelated('Win32_NetworkAdapterConfiguration') } | Where-Object {$_.IPEnabled -eq '$True'}


IF ($LAN.IPConnectionMetric -eq $Null -or $WLAN.IPConnectionMetric -eq $Null) {"COMPLIANT"}

elseif ($LAN.IPConnectionMetric -lt $WLAN.IPConnectionMetric) {"COMPLIANT"} 

else {$null}


