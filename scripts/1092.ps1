#The PowerShell Talk
#Virtualization Congress 2009
#
#Provision from CSV (csv-provision.ps1)

#Grab from the cli the path to the csv file
Param ( $path_to_csv )

#Get credentials & Connect
Get-Credential | connect-viserver -server "Your vCenter Here"

#Import the CSV, and build our VMs
$csv = Import-Csv -Path $path_to_csv
$csv | foreach-object {
    New-VM -Name $_.ServerName -NumCPU $_.CPU -Resourcepool $acct -NetworkName "Replace This" -MemoryMB $_.RAM -DiskMB $_.DISK -GuestId $_.OS -Datastore "supernova-staging" -vmhost "178331-kickstart2.iad1.rvi.local" -CD -RunAsync 
}
