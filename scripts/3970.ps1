# This script runs a different OVF conversion depending on the Day of the week.
$VeeamJob = "JobName"
$server1 = 'ServerName'

asnp VMware.VimAutomation.Core -ErrorAction SilentlyContinue
asnp VeeamPSSnapin -ErrorAction SilentlyContinue

$Dest1 = "R:\VMWARE\OVF\$Server1\"

$OVFFile1 = "$($Dest1)$($Server1).ovf"

$VmIRName1 = $Server1 + "_ovf"

# Name of vCenter to Export VM From
$VcName = "vCenterServer"
# Name of ESX host for Instant VM Restore
$EsxHost = "SingleESXHost"
# Path to OVF Tool on your system
$OVFTool = "D:\Program Files\VMware\VMware OVF Tool\ovftool.exe"
# Date
$Date = get-date -Format yy-MM-dd
$TimeStamp = get-date 
# Path of Log file
$Log = "D:\logs\VMWare\" + $Date + ' ' + $Server1 + " OVF to AWS.log"
# Email sender address
$EmailTo = 'Address@Domain.com'
$EmailFrom = 'Address@Domain.com'

#############################################################################################
$error.clear()
Add-content -Path $Log -Value "Backup of Server $Server1 Started at $TimeStamp"
# Find most recent restore point for VM
$ExportObj1 = (Get-VBRBackup -name "$VeeamJob").GetLastOibs() | Where-Object {$_.Name -eq $Server1}

# Get ESX Server and Resource Pool and start Instant Recovery with VM powered off
$EsxObj1 = Get-VBRServer -Name "$EsxHost"
$ResourcePoolObj = Find-VBRResourcePool -Server $EsxObj1 -Name "Resources" 
Start-VBRInstantRecovery -RestorePoint $ExportObj1 -VMName $VmIRName1 -Server $EsxObj1 -ResourcePool $ResourcePoolObj -PowerUp $false -NICsEnabled $true
if (!$?) {
	Add-Content -Path $Log -Value "$server1 InstantRecovery failed with Error (error code:0x00000080): $error"
	Add-Content -Path $Log -Value "Stopping the backup of $Server1"
	Break}
Else{
	Add-Content -Path $Log -Value "$Server1 InstantRecovery Started successfully..."
	# Connect to vCenter and get the Instant Recovery VM
	Connect-VIServer $VCName -User 'ESXAdminUser' -Password 'Password' 
	if (!$?) {
		Add-Content -Path $Log -Value "$server1 Connection to vCenter failed with Error (error code:0x00000079): $error"
		Add-Content -Path $Log -Value "Stopping the backup of $Server1"
		Break}
	Else{
		Add-Content -Path $Log -Value "$Server1 Connection to VI Server was successful..."
		$VmIR1 = Get-VM -Name "$VmIRName1"
		# Get session and ticket
		$Session = Get-View -Id Sessionmanager
		$Ticket = $Session.AcquireCloneTicket()
		# Call OVFtool to 
		& $OVFTool "--name=$Server1" "--noSSLVerify" "--targetType=OVF" "--overwrite" "--I:sourceSessionTicket=$($Ticket)" "vi://$($VcName)?moref=vim.VirtualMachine:$($VmIR1.extensiondata.moref.value)" "$($Dest1)$($Server1).ovf"
		if (!$?) {
			Add-Content -Path $Log -Value "$server1 OVF conversion and transfer failed with Error (error code:0x00000078): $error"
			Add-Content -Path $Log -Value "Stopping the backup of $Server1"
			Break}
		Else{
			Add-Content -Path $Log -Value "$Server1 OVF conversion and transfer completed successfully..."
			# Remove VM from vCenter Inventory and Stop Instant VM Recovery
			$IR1 = Get-VBRInstantRecovery | where-object {$_.VMName -eq "$VMIRName1"}
			Stop-VBRInstantRecovery $IR1
			if (!$?) {
				Add-Content -Path $Log -Value "$server1 Stop InstantRecovery failed with Error (error code:0x0000077): $error"
				Add-Content -Path $Log -Value "Stopping the backup of $Server1"
				Break}
			Else{
				Add-Content -Path $Log -Value "$Server1 stopping of the Instant Recovery completed successfully..."
				Remove-VM $VmIR1 -Confirm:$false 
				if (!$?) {
					Add-Content -Path $Log -Value "$server1 Removal of Server_OVF Failed with Error (error code:0x00000076): $error"
					Add-Content -Path $Log -Value "Stopping the backup of $Server1"
					Break}
				Else{
					Add-Content -Path $Log -Value "$Server1 Removeal of the temp OVF completed successfully..."
					# disconnect from vCenter
					Disconnect-VIServer $VCName -Confirm:$False
					if (!$?) {
						Add-Content -Path $Log -Value "$server1 failed to disconnect from the vCenter server with Error (error code:0x00000075): $error"
						Add-Content -Path $Log -Value "Stopping backup of $Server1"
						Break}
					Else{
						Add-Content -Path $Log -Value "$Server1 OVF conversion and transfer completed successfully (OK) at $TimeStamp..."
						
					}
				}
			}
		}
	}
}

#################################################################
#		Check backup status and send notification				#
#################################################################
#Check OVF has completed
$Failed = Get-Content $log | Select-String "0x000000" -quiet
$Success = Get-Content $log | Select-String "(OK)" -quiet

# Email server
$PSEmailserver = 'EmailServer' 
# Email subject depends on the log file, if there is an error in the log file set subject to failed. if there is an OK in the log set to success, otherwise set to unknown
If ($Failed){$Subject = $Server1 + ' OVF backup failed'}
Elseif ($Success) {$subject = $Server1 + ' OVF backup Success'}
else {$subject = "UNKNOWN OVF backup Result"}

# Send an email with details. 
Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $Subject -attachments $log -Body "See the log file for the results of the OVF backup of $Server1"
