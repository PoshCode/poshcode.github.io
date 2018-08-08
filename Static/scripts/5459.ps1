gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards\*' | % {
  $ht = @{}
}{
  $ht[$_.Description] = $_.ServiceName
}{
  $ht.GetEnumerator() | % {
    "{0} - {1}" -f $_.Name, (
      gp "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$(
        $_.Value
      )"
    ).DhcpIPAddress
  }
}
