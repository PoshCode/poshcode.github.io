$key = @(
    'HKLM:\SYSTEM\CurrentControlSet',
    '\Services\Tcpip\Parameters\Interfaces\',
    '\Control\Class\',
    '\Control\Network\*\*\Connection'
)

(gp ($key[0] + $key[1] + (gp ($key[0] + `
$key[2] + (gp ($key[0] + '\Enum\' + (gp ($key[0] + $key[3]) | ? {
        $_.MediaSubType -eq 2
      }).PnpInstanceID)
    ).Driver)
  ).NetCfgInstanceID)
).DhcpIPAddress
