# Connect to vCenter
Connect-VIServer vcenter.domain.com

# root folder is used for datacenter location
$rootfolder = Get-Folder -NoRecursion

# datacenter
$dc = New-Datacenter -Name "vFarm" -Location $rootfolder

# Build hostname strings for ESX servers in format sssrrrnn (site/role/number)
$esxname = 1..10 | ForEach-Object { "atlesx{0:00}" -f $_ }

# prompt for ESX server credentials
$esxcred = Get-Credential

# Add ESX servers to vCenter
$vmhost = $esxname | ForEach-Object { 
	Add-VMHost -Name $_ -Credential $esxcred
}

# Customer codenames, same number as there are hosts
$custname = "TGT", "WAL", "THD", "LOW", "KRO", "CVS", "TOY", "MAC", "SEA", "OLD"

# Create customer resource pools, one per ESX host
$rpool = for ( $i = 0; $i -lt $vmhost.length; $i++ ) {
	# Can set resource settings such as mem or cpu limit here
	New-ResourcePool -Location $vmhost[$i] -Name $custname[$i] 
}

# Create array of hashtables (think of it like a spreadsheet) 
# describing role names and number of VMs in each
$roleinfo = @(
	@{ Name = "ProxyServer"; Num = 2 },
	@{ Name = "WebServer"; Num = 4 },
	@{ Name = "AppServer"; Num = 2 },
	@{ Name = "DBServer"; Num = 2 }
)

# Create role resource pools and all VMs
foreach ( $custpool in $rpool ) {
	foreach ( $role in $roleinfo ) {
		# Create role resource pool
		$rolepool = New-ResourcePool -Name $role["Name"] -Location $custpool
		
		# Use number field to determine how many VMs to make and what to name them
		1..$role["Num"] | ForEach-Object {
			# Create VM name, e.g. KRO-WebServer-1
			$vmname = $custpool.Name + "-" + $role["Name"] + "-$_"
			
			# Create VM based on predefined templates
			New-VM -Name $vmname -ResourcePool $rolepool -Template $role["Name"] 
		}
	}
}
