
################################################################################################################
# VMWare Standard Scripts - PowerCLI
#
# Purpose:  Mount NFS datastore on new host server using reference host datstore
# Author:   David Chung
# Docs:     NA
# Date: 	2/4/2012	
#
#
# Instruction: 	Enter VI server name, Reference Host server name
#		Modify $hostincluster value either $true or $false
#		$false value will only update single ESX host server with NFS mount
# 
################################################################################################################

$HostinCluster = $false

$viserver = Read-Host "Enter VI server"
$refhost = Read-Host "Enter Reference host server"


Connect-VIServer $viserver
$REFHOST = Get-VMHost $refhost
If ($HostinCluster) {
	$cluster = Read-Host "Enter Cluster that has new host servers"
	$NEWHosts = Get-Cluster $cluster | Get-VMHost | sort name
	foreach($nfs in (Get-VMhost $REFHOST | Get-Datastore | Where {$_.type -eq "NFS"} )){
	    [string]$remotePath = $nfs.extensiondata.info.nas.remotepath
	    [string]$remoteHost = $nfs.extensiondata.info.nas.remotehost
	    [string]$shareName = $nfs.Name
		
		Foreach ($NEWHost in $NEWHosts) {
		    If ((Get-VMHost $NEWHOST | Get-Datastore | Where {$_.Name -eq $shareName -and $_.type -eq "NFS"} -ErrorAction SilentlyContinue )-eq $null){
		        Write-Host "NFS mount $shareName doesn't exist on $($NEWHOST.name)" -fore Red
		        New-Datastore -Nfs -VMHost $NEWHost.name -Name $Sharename -Path $remotePath -NfsHost $remoteHost    | Out-Null
		    }
		}	
	}
}

Else {
	$NEWHOST = Read-Host "Enter new host name"
	$Newhost = Get-VMHost $NEWHost
	foreach($nfs in ($REFHOST | Get-Datastore | Where {$_.type -eq "NFS"} )){
	    [string]$remotePath = $nfs.extensiondata.info.nas.remotepath
	    [string]$remoteHost = $nfs.extensiondata.info.nas.remotehost
	    [string]$shareName = $nfs.Name
		
		If (($NEWHOST | Get-Datastore | Where {$_.Name -eq $shareName -and $_.type -eq "NFS"} -ErrorAction SilentlyContinue )-eq $null){
		    Write-Host "NFS mount $shareName doesn't exist on $($NEWHOST.name)" -fore Red
		    New-Datastore -Nfs -VMHost $NEWHost.name -Name $Sharename -Path $remotePath -NfsHost $remoteHost    | Out-Null
		}
	}
}	
