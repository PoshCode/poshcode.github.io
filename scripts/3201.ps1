# Variables
$viserver = Read-Host "Enter VI server name"
$cluster = Read-Host "Enter Cluster name"
$vmhelper = Read-Host "Enter VM_HELPER name"

Write-Host "Connecting to $viserver..."
Connect-VIServer $viserver -WarningAction:SilentlyContinue

# Get VM Hosts
$vmhosts = Get-Cluster $cluster -ErrorAction:SilentlyContinue | Get-VMHost | where {$_.powerstate -eq "poweredon"} | sort name 
If ($vmhosts -eq $null) {
	Write-Host "Invalid cluster name"
	break
}
$vmhosts | select name 
Write-Host "Listed servers will be tested for virtual machine VLAN"
Write-Host "Verify that $cluster cluster is NOT A PRODUCTION cluster"
Write-Host "Press Any Key to Continue..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host 

# Get VM IP
Write-Host "Getting VM IP(s) from $vmehlper virtual machine VLAN...."
$vm = Get-VM $vmhelper -ErrorAction:SilentlyContinue
if ($vm -eq $null) {
	Write-Host "Invalid VM name"
	break
}	
$vm.guest.nics | select NetworkName, IPAddress 
$answer = Read-host "Do you want to continue with current IP address? (yes/no)"

# Start VLAN Ping
if ($answer -eq "yes") {
	$vm.guest.nics | foreach {
		$vmnic = $_
		$pingfile = "c:\scripts\"+ $vmnic.networkname + ".cmd"
		$pingcmd = "ping -t " + $vmnic.IPAddress 
		Add-Content $pingfile $pingcmd 
		Start-Process $pingfile
	}
# Prep Vmotion by moving VM to last host
	Write-Host "Moving $vmhelper to " ($vmhosts| select -last 1) "..."
	Move-VM -VM $vmhelper -Destination ($vmhosts | select -last 1) -Confirm:$false -ErrorAction:SilentlyContinue | Out-Null

# Start Vmotion on two pass-thru NIC
	Foreach ($vmhost in $vmhosts) {
		Write-Host "Moving $vmhelper to $vmhost... Check continuous ping"
		Move-VM -VM $vmhelper -Destination $vmhost -Confirm:$false -ErrorAction:SilentlyContinue | Out-Null
		if (($vmhost | Get-VM $vmhelper) -eq $nul) {
			Write-Host "Vmotion to $vmhost failed.  Check settings"
			break
		}	
	}

# Remove vmnic1 from vSiwtch0
	Foreach ($vmhost in $vmhosts) {
		$vSwitch = $vmhost | Get-VirtualSwitch | Where-Object {$_.Name -eq "vSwitch0"}
		Write-Host "Removing vmnic1 from $vmhost..."
		$vSwitch | Set-VirtualSwitch -Nic vmnic0 -Confirm:$false | Out-Null
	}
	sleep 10

# Start Vmotion on two pass-thru NIC
	Foreach ($vmhost in $vmhosts) {
		Write-Host "Moving $vmhelper to $vmhost... Check continuous ping"
		Move-VM -VM $vmhelper -Destination $vmhost -Confirm:$false -ErrorAction:SilentlyContinue | Out-Null
		if (($vmhost | Get-VM $vmhelper) -eq $null) {
			Write-Host "Vmotion to $vmhost failed.  Check settings"
			break	
		}
	}	

# Remove vmnic0 from vSiwtch0
	Foreach ($vmhost in $vmhosts) {
		$vSwitch = $vmhost | Get-VirtualSwitch | Where-Object {$_.Name -eq "vSwitch0"}
		Write-Host "Removing vmnic0 from $vmhost..."
		$vSwitch | Set-VirtualSwitch -Nic vmnic1 -Confirm:$false | Out-Null
	}
	sleep 10

	Foreach ($vmhost in $vmhosts) {
		Write-Host "Moving $vmhelper to $vmhost... Check continuous ping"
		Move-VM -VM $vmhelper -Destination $vmhost -Confirm:$false -ErrorAction:SilentlyContinue | Out-Null
	}	

# Add vmnic0 and vmnic1 back to vSwitch0
	Write-Host "Re-Adding vmnic0 and vmnic1 to vSwitch0..."		
	Foreach ($vmhost in $vmhosts) {		
		$vSwitch = $vmhost | Get-VirtualSwitch | Where-Object {$_.Name -eq "vSwitch0"}
		Write-Host "Adding vmnic0, vmnic1 on $vmhost..."
		$vSwitch | Set-VirtualSwitch -Nic vmnic0,vmnic1 -Confirm:$false | Out-Null
	}
	$vm.guest.nics | foreach {
		$vmnic = $_
		$pingfile = "c:\scripts\"+ $vmnic.networkname + ".cmd"
		del $pingfile
	}
	Write-Host "Test is completed."	
}		




