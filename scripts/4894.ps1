# Script to create scratch location directory per host
# By Leon Scheltema AVANCE ICT Groep Nederland

# Begin variables
$Datastore = ""
# End variables

#connect to all host from csv sequentially

Import-CSV file.csv | ForEach-Object {
$hostname = $_.vmhost

connect-viserver $hostname -user root -password ""

#Mount a datastore read/write as a PSDrive
New-PSDrive -Name "mounteddatastore" -Root \ -PSProvider VimDatastore -Datastore (Get-Datastore $Datastore)

#Access the new PSDrive
Set-Location mounteddatastore:

#Create a uniquely-named directory for this ESXi host
New-Item ".locker-$hostname" -ItemType directory

#Unmount a datastore read/write as a PSDrive
CD G:
Remove-PSDrive Mounteddatastore

#Change the Scratch location by specifying the full path to the directory created earlier
Set-VMHostAdvancedConfiguration -Name "ScratchConfig.ConfiguredScratchLocation" -Value "/vmfs/volumes/$Datastore/.locker-$hostname"

# Disconnect from vCenter server
Disconnect-VIServer -server $hostname -Force -Confirm:$false
}
