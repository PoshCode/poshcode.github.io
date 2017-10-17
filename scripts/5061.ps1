<#
# Checking IP address with cmd:
# C:\> ipconfig
#
# Right? But what if you haven't enough rights to launch ipconfig?
# C:\> for /f "tokens=3" %i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces /s ^| findstr DhcpIP') do @echo %i
#
# With PowerShell
#>
gp HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\* | % {if (($ip = $_.DhcpIPAddress) -ne '0.0.0.0') {$ip}}
