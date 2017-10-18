$key = 'HKLM:\SYSTEM\CurrentControlSet'

(gp ($key + '\Services\Tcpip\Parameters\Interfaces\' + `
(Split-Path -Leaf (gp ($key + '\Control\Network\*\*\Connection') | ? {
  $_.MediaSubType -eq 2
}).PSParentPath))).DhcpIPAddress
