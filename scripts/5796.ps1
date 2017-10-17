function set-ipmetricWLAN {

param ( [uint32]$metric ) 

      $LAN = 
      Get-WmiObject Win32_NetworkAdapter -Filter "AdapterType='Ethernet 802.3'" |
      Where-Object { ($_.NetConnectionID -notlike '*Wireless*' -or $_.NetConnectionID -notlike '*WiFi*' -or $_.NetConnectionID -notlike '*Wi-Fi*' ) -and $_.ServiceName -notlike '*NETw*' } |
      ForEach-Object { $_.GetRelated('Win32_NetworkAdapterConfiguration') } | Where-Object {$_.IPEnabled -eq '$True'}

      $WLAN = 
      Get-WmiObject Win32_NetworkAdapter -Filter "AdapterType='Ethernet 802.3'" |
      Where-Object { ($_.NetConnectionID -like '*Wireless*' -or $_.NetConnectionID -like '*WiFi*' -or $_.NetConnectionID -like '*Wi-Fi*' -or $_.ServiceName -like '*NETw*') } |
      ForEach-Object { $_.GetRelated('Win32_NetworkAdapterConfiguration') } | Where-Object {$_.IPEnabled -eq '$True'}
      
   
$WLAN | Invoke-WmiMethod -Name SetIPConnectionMetric -ArgumentList ($LAN.IPConnectionMetric + $metric)

      
}

set-ipmetricWLAN -metric 100

