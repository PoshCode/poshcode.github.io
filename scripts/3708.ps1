<#Time Synchronization Status#>
	
	Write-Host "Time Synchronization Status" -ForegroundColor Yellow
	Write-Host "_______________________________" -ForegroundColor Yellow
	Write-Host
	
	$VMhost = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters" | select -ExpandProperty physicalhostname
	$VirtualMachineName = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters" | select -ExpandProperty VirtualMachineName
	$session = New-PSSession -ComputerName $vmhost
	Invoke-Command -Session $session {
	param($vmname)
	$MgmtSvc = gwmi -namespace root\virtualization MSVM_VirtualSystemManagementService
	$VM = gwmi -namespace root\virtualization MSVM_ComputerSystem |?{$_.elementname -match $vmname}
	$TimeSyncComponent = gwmi -query "associators of {$VM} where ResultClass = Msvm_TimeSyncComponent" -namespace root\virtualization                
	$TimeSyncSetting  = gwmi -query "associators of {$TimeSyncComponent} where ResultClass = Msvm_TimeSyncComponentSettingData" -namespace root\virtualization                
	# Disable = 3; Enable = 2        
	if ($TimeSyncSetting.EnabledState -eq 3 ){
	Write-Host "Time Synchronzation Disabled"  -ForegroundColor Green 
	}
	else{ Write-Host "Time Synchronzation Enabled" -ForegroundColor Red }
	} -Args $VirtualMachineName
	Get-PSSession | Remove-PSSession
	
