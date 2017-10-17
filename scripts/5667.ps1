# Script to create Datastore clusters and add datastores from csv
# By Leon Scheltema AVANCE ICT Groep Nederland

# Begin variables
$VC1 = "New vCenter"
$DSCluster = "Datastore Cluster"
# End variables

# Connect to vCenter server
Connect-VIServer "$VC1"

Set-DatastoreCluster -DatastoreCluster $DSCluster -SdrsAutomationLevel FullyAutomated

Import-CSV $DSCluster.csv | ForEach-Object {

	$Datastore = $_.Name

move-datastore -Datastore $Datastore -Destination $DSCluster

# Disconnect from vCenter server
Disconnect-VIServer -server "$VC1" -Force -Confirm:$false
