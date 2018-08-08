# script parameters
param(
[string[]] $Computers = $env:computername,
[switch] $ChangeSettings,
[switch] $EnableDHCP,
[switch] $IpRelease
)

# script variables
$nl = [Environment]::NewLine
$Domain = "domain.local"
$DNSSuffix = @("domain.local,domain.com")
$DNSServers = @("10.10.0.1", "10.10.0.2", "10.10.0.3", "10.10.0.4")
$WINSServers = @("10.10.0.5", "10.10.0.6")
$Gateway = @("10.10.255.254")

# script functions
Function ChangeIPConfig($NIC){
	if ($EnableDHCP){
		$NIC.EnableDHCP()
		$NIC.SetDNSServerSearchOrder()
		}
	else{
		$DNSServers = Get-random $DNSservers -Count 4
		$NIC.SetDNSServerSearchOrder($DNSServers)
		#$x = 0
		#$IPaddress = @()
		#$NetMask = @()
		#$Gateway = @()
		#$Metric = @()
		#foreach ($IP in $NIC.IPAddress){
			#$IPaddress[$x] = $NIC.IPAddress[$x]
			#$NetMask[$x] = $NIC.IPSubnet[$x]
			#$Gateway[$x] = $NIC.DefaultIPGateway[$x]
			#$Metric[$x] = $NIC.GatewayCostMetric[$x]
			#$x++
		#}
		#$NIC.EnableStatic($IPaddress, $NetMask)
		#$NIC.SetGateways($Gateway, $Metric)
		#$NIC.SetWINSServer($WINSServers)
		}
	$NIC.SetDynamicDNSRegistration("TRUE")
	$NIC.SetDNSDomain($Domain)
	# remote WMI registry method for updating DNS Suffix SearchOrder
	$registry = [WMIClass]"\\$computer\root\default:StdRegProv"
	$HKLM = [UInt32] "0x80000002"
	$registry.SetStringValue($HKLM, "SYSTEM\CurrentControlSet\Services\TCPIP\Parameters", "SearchList", $DNSSuffix)
}

Function ShowDetails($NIC, $Computer){
	Write-Output "$($nl)$(" IP settings on: ")$($Computer.ToUpper())$($nl)$($nl)$(" for") $($NIC.Description)$(":")$($nl)"
	Write-Output "$("Hostname = ")$($NIC.DNSHostName)"
	Write-Output "$("DNSDomain= ")$($NIC.DNSDomain)"
	Write-Output "$("Domain DNS Registration Enabled = ")$($NIC.DomainDNSRegistrationEnabled)"
	Write-Output "$("Full DNS Registration Enabled = ")$($NIC.FullDNSRegistrationEnabled)"
	Write-Output "$("DNS Domain Suffix Search Order = ")$($NIC.DNSDomainSuffixSearchOrder)"
	Write-Output "$("MAC address = ")$($NIC.MACAddress)"
	Write-Output "$("DHCP enabled = ")$($NIC.DHCPEnabled)"
	# show all IP adresses on this NIC
	$x = 0
	foreach ($IP in $NIC.IPAddress){
		Write-Output "$("IP address $x =")$($NIC.IPAddress[$x])$("/")$($NIC.IPSubnet[$x])"
		$x++
	}
	Write-Output "$("Default IP Gateway = ")$($NIC.DefaultIPGateway)"
	Write-Output "$("DNS Server Search Order = ")$($NIC.DNSServerSearchOrder)"
}

# actual script execution
foreach ($Computer in $Computers){
	If (Test-connection $Computer -quiet -count 1){
		Try {
			[array]$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -Computername $Computer -EA Stop | where{$_.IPEnabled -eq "TRUE"}
			}
		Catch {
			Write-Warning "$($error[0])"
			Write-Output "$("INACCESIBLE: ")$($nl)$($Computer.ToUpper())"
			Write-Host $nl
			continue
			}
		# Generate selection menu
		$NICindex = $NICs.count
		Write-Host "$nl Selection for "$Computer.ToUpper() ": $nl"
		For ($i=0;$i -lt $NICindex; $i++) {
			Write-Host -ForegroundColor Green "$i --> $($NICs[$i].Description)"
			Write-Output $(ShowDetails $NICs[$i] $Computer)
			}
		$nl
		Write-Host -ForegroundColor Green "q --> Quit" $nl
		# Wait for user selection input
		Do {
			$SelectIndex = Read-Host "Select connection by number or 'q' (=default) to quit"
			Switch -regex ($SelectIndex){
				"^q.*"{$SelectIndex="quit"; $kip = $true}
				"\d"{$SelectIndex = $SelectIndex -as [int]}
				"^\s*$"{$SelectIndex="quit"; $kip = $true}
			}
		}
		Until (($SelectIndex -lt $NICindex) -OR $SelectIndex -like "q*")
		$nl
		Write-Host "You selected: $SelectIndex"
		#skip current $computer if $true
		If ($kip) {continue} 
	# Change settings for selected network card if option is true and show updated values
	If ($ChangeSettings){
		If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
		Write-Warning "You need Administrator rights to run this script!"
		Break
		}
		If ($IpRelease){
			#$NICs[$SelectIndex].ReleaseDHCPLease
			$NICs[$SelectIndex].RenewDHCPLease
			}
		Else{
			ChangeIPConfig $NICs[$SelectIndex]
			}
			start-sleep -s 2
			Write-Host $nl "    ====NEW SETTINGS====" $nl
			$UpdatedNIC = Get-WMIObject Win32_NetworkAdapterConfiguration -Computername $Computer | where{$_.Index -eq $NICs[$SelectIndex].Index}
			Write-Output $(ShowDetails $UpdatedNIC $Computer)$($nl)
		}
	Else{
		If ($SelectIndex -notlike "q*"){
			$nl
			Write-Warning "For changing settings add -ChangeSettings as parameter, if not this script is output only"
			$nl
			}
		}
	}
}

