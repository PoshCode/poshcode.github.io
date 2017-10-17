param([String] $DomainName = '192.168.0.1')
$socket = New-Object System.Net.Sockets.Socket ([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)

$Socket.Connect('whois.arin.net', 43) | out-null
$bytes = [System.Text.Encoding]::ASCII.GetBytes($domainName + "`n")
$Socket.Send($bytes) | out-null
$bytes = [Array]::CreateInstance("byte", 2048)
$Socket.Receive($bytes) | out-null
$result = [System.Text.Encoding]::ASCII.GetString($bytes).Trim()
$Socket.Close()

$Data = New-Object Object
$Data | Add-Member NoteProperty Raw ($result)
$result -split "`n" | % {
  if (![String]::IsNullOrEmpty($_)) {
    $num = $_.IndexOf(":")    
    if ($num -gt 0) {
      $itemName = $_.SubString(0,$num).Trim()
      $itemValue = $_.SubString($num+1).Trim()
      
      if (($Data | Get-Member $itemName)) {
        $Data.($itemName) += "|" + $itemValue
      }
      else {
        $Data | Add-Member NoteProperty ($itemName) ($itemValue)
      }
    }
  }
}

$Data
