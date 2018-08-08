# Import vCenter Folder structure incl VM relations
# By Leon Scheltema AVANCE ICT Groep Nederland
# Functions used by Grzegorz Kulikowski / Robert van den Nieuwendijk

# Begin variables
$NewVC = "New vCenter"
# End variables

# Connect to vCenter server
Connect-VIServer "$NewVC"

$vmlist = Import-Csv "migratedvms.csv"
move-vm -vm $vmlist[0].name -Location (get-view -id $vmlist[0].folder -Server $newVC|get-viobjectbyviview) -Server $NewVC

# Disconnect from vCenter server
Disconnect-VIServer -server "$NewVC" -Force -Confirm:$false
