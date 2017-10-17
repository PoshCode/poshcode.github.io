# fastNFS
# Description: Mounts NFS datastore to a group of ESX hosts.
# Usage: Enter a list of ESX hosts (by IP or hostname). Then enter the IP, path, and datastore name of the share.
#
#
# Enter the name or IP of the NFS server
$nfssrv = Read-Host "Enter the name or IP of the NFS server"
 
# Enter the full path to the share
$nfspath = Read-Host "Enter the full path to the share"
 
# Give a name for the new NFS datastore
$nfsds = Read-Host "Enter a name for the new NFS datastore"
 
# Create an empty array for $esx
$esx = @()
 
# Will continue to prompt for ESX hosts until you stop entering them.
do {
    $input = Read-Host "Add an ESX host by FQDN or IP"
    if ($input -ne ""){
        $esx += $input
    }
   }
until ($input -eq "")
 
# Mounts the datastore
foreach ($name in $esx)
        {
        New-Datastore -VMHost $name -Name $nfsds -Path $nfspath -Nfshost $nfssrv -Nfs
        }
