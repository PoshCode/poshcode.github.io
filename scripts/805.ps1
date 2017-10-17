# Enumerate fan speeds on an ESX host that is running WSMAN.
# This doesn't take advantage of CTP3's WSMAN cmdlets.
# Needs winrm installed.
$serverName = "your.server"
$user = "root"
$password = "password"
$x = [xml](winrm enumerate `
  http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_NumericSensor `
  "-username:$user" "-password:$password" "-auth:basic" "-skipCAcheck" `
  "-skipCNcheck" "-r:https://$serverName/wsman" "-format:pretty")
$pattern = "(?<ID>FAN .)"
$x.Results.OMC_NumericSensor
