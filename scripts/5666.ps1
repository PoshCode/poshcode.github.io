# Script to export Datastore information per Datastore cluster to csv
# By Leon Scheltema AVANCE ICT Groep Nederland

# Begin variables
$VC1 = "Old vCenter"
$DSCluster = "Datastore Cluster"
# End variables

# Connect to vCenter server
Connect-VIServer "$VC1"

Get-DatastoreCluster -name $DSCluster | Get-Datastore  | Select-object Name | Export-Csv $DSCluster.csv

# Disconnect from vCenter server
Disconnect-VIServer -server "$VC1" -Force -Confirm:$false
