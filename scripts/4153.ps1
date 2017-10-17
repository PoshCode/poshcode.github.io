# Script to get creator and creation date and add to custom attribute
# second part of the script checks latest Netapp snapshot used for backup purposes and adds to custom attribute

if (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
	Add-PSSnapin VMware.VimAutomation.Core
}
if (-not (Get-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue)) {
	Add-PSSnapin Quest.ActiveRoles.ADManagement
}
$VC1 = "VI server"
# Connect to vCenter server
Connect-VIServer "$VC1"
# Get all VMs from selected Datacenter

$VMs = Import-Csv Clusters.csv | 
	Foreach {Get-Cluster -Name $_.Name | Get-VM | Sort Name}
$VM = $VMs | Select -First 1


# Check if fields CreatedBy, Createdon and LastBackup exist. If not create them
If (-not $vm.CustomFields.ContainsKey("CreatedBy")) {
	Write-Host "Creating CreatedBy Custom field for all VM's"
	New-CustomAttribute -TargetType VirtualMachine -Name CreatedBy | Out-Null
}
If (-not $vm.CustomFields.ContainsKey("CreatedOn")) {
	Write-Host "Creating CreatedOn Custom field for all VM's"
	New-CustomAttribute -TargetType VirtualMachine -Name CreatedOn | Out-Null
}
If (-not $vm.CustomFields.ContainsKey("LastBackup")) {
	Write-Host "Creating LastBackup Custom field for all VM's"
	New-CustomAttribute -TargetType VirtualMachine -Name LastBackup | Out-Null
}
# Get User account and creation information for each VM and fill corresponding fields
Foreach ($VM in $VMs){
	If ($vm.CustomFields["CreatedBy"] -eq $null -or $vm.CustomFields["CreatedBy"] -eq ""){
		Write-Host "Finding creator for $vm"
		$Event = $VM | Get-VIEvent -Types Info | Where {$_.Gettype().Name -eq "VmBeingDeployedEvent" -or $_.Gettype().Name -eq "VmCreatedEvent" -or $_.Gettype().Name -eq "VmClonedEvent"}
		If (($Event | Measure-Object).Count -eq 0){
			$User = "Unknown"
			$Created = "Unknown"
		} Else {
			If ($Event.Username -eq "" -or $Event.Username -eq $null) {
				$User = "Unknown"
			} Else {
				$User = (Get-QADUser -Identity $Event.Username).DisplayName
				if ($User -eq $null -or $User -eq ""){
					$User = $Event.Username
				}
				$Created = $Event.CreatedTime
			}
		}
		Write "Adding info to $($VM.Name)"
		Write-Host -ForegroundColor Yellow "CreatedBy $User"
		$VM | Set-Annotation -CustomAttribute "CreatedBy" -Value $User | Out-Null
		Write-Host -ForegroundColor Yellow "CreatedOn $Created"
		$VM | Set-Annotation -CustomAttribute "CreatedOn" -Value $Created | Out-Null
	}
}
# Get info about latest Snapshot created/removed by Netapp service account for backup purposes and fill corresponding field
Foreach ($VM in $VMs){
		Write-Host "Finding snapshot for $vm"
		$Event = $VM | Get-VIEvent -Username "Netapp-service-account" -MaxSamples 3 | where {$_.GetType().Name -eq "TaskEvent" -and $_.Info.Name -eq "RemoveSnapshot_task"}
				$Result = $Event.CreatedTime
		Write "Adding info to $($VM.Name)"
		Write-Host -ForegroundColor Yellow "Snapshot $User"
		$VM | Set-Annotation -CustomAttribute "LastBackup" -Value $Result | Out-Null}
		
	
Disconnect-VIServer -server "$VC1" -Force -Confirm:$false


