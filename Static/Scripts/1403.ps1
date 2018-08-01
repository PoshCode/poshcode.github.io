[system.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
	Where-Object { $_.GetIPProperties().GatewayAddresses } |
		ForEach-Object {
			$_.GetIPProperties().UnicastAddresses| ForEach-Object {
				$_.Address.IPAddressToString
			}
		}
