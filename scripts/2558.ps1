param (
	[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String[]]$HostnameOrIPs
)
process {
	ForEach ($HostnameOrIP in $HostnameOrIPs) {
		try {
			$result = [System.Net.Dns]::GetHostEntry($HostnameOrIP)
			"" | select @{Name='HostName'; Expression={$result.HostName}}, @{Name='AddressList'; Expression={$result.AddressList}}
		}
		catch {
			Write-Warning ("[{0}] Lookup failed: {1}" -f $HostnameOrIP, $_.exception.InnerException.message)
		}
	}
}
