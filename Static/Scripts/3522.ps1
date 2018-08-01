Function Get-mDatastoreList {
#Parameter- Name of the VMware cluster to choose a datastore from.
param($Cluster)

#get alphabetically last ESX host in the VMware cluster (it's likely the last host added to the cluster, so this might smoke out any problems)
$VMH = get-vmhost -Location $cluster | Where-Object { ($_.ConnectionState -eq "Connected") -and ($_.PowerState -eq "PoweredOn") } | Select-Object -Property Name | Sort-Object Name | Select -Last 1 -Property Name

# Get all the datastores, filtered for exclusions
$DSTs = Get-Datastore -VMHost $VMH.Name | Where-Object { ($_.Type -eq "VMFS") -and ($_.Name -notmatch "local") -and ($_.Name -notmatch "iso") -and ($_.Name -notmatch "template") -and ($_.Name -notmatch "datastore") -and ($_.Name -notmatch "temp") -and ($_.Name -notmatch "decom") -and ($_.Name -notmatch "_BED-PR") -and ($_.Name -notmatch "VMAX") -and ($_.Name -notmatch "NEW")  -and ($_.Name -notmatch "MAY-PR-LEG") -and ($_.Name -notmatch "BED-QA-LEG") }

Write-Output $DSTs
}

#20110617 cmonahan- removed filters for "CLD" and "TRX"
#20110629 cmonahan- filtering out BED-PR-31 and BED-PR-32, reserved for mongodb VMs

