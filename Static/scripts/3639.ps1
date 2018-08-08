#Requires input from the user
$Server = read-host "Enter Exchange Server Name"

#Finds only the services that contain "Exchange"
$Status = (Get-Service -ComputerName $server |Where-object {$_.Displayname -like "*Exchange*"})

#Displays which Exchange Services are stopped
  foreach ($Name in $status) {
     IF ($Name.status -eq "Stopped"){Write-Host $Name.displayname "was stopped" -foreground red}} 

#Starts all stopped services
  foreach ($Name in $status) {
     IF ($Name.status -eq "Stopped"){Start-Service -InputObject $Name}}

#Displays all Exchange services and their Status  
Get-Service -ComputerName $server |Where-object {$_.Displayname -like "*Exchange*"
}
