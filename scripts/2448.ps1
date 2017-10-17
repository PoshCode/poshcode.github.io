Function mGet-DatastoreList {
#Parameter- Name of the VMware cluster to choose a datastore from.
param($Cluster)

#get alphabetically last ESX host in the VMware cluster (it's likely the last host added to the cluster, so this might smoke out any problems)
$VMH = get-vmhost -Location $cluster | Where-Object { ($_.ConnectionState -eq "Connected") -and ($_.PowerState -eq "PoweredOn") } | Select-Object -Property Name | Sort-Object Name | Select -Last 1 -Property Name

# Get all the datastores, filtered for exclusions
$DSTs = Get-Datastore -VMHost $VMH.Name | Where-Object { ($_.Type -eq "VMFS") -and ($_.Name -notmatch "local") -and ($_.Name -notmatch "iso") -and ($_.Name -notmatch "template") -and ($_.Name -notmatch "CLD") -and ($_.Name -notmatch "TRX") }

Write-Output $DSTs
}


