Function Get-MyDomain() {
# Written by Jeremy D. Pavleck - Pavleck.NET
$IP = ((Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property IPAddress -First 1).IPAddress[0])
  trap {
    return "Unknown:$($IP)"
	}
return [System.Net.DNS]::GetHostByAddress($IP).HostName
}
