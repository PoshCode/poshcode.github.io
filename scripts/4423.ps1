#-----------------------------------------------------------------------
# Script creates one-way connections between one sending member server 
# and a list of receiving member servers. The group schedule is used.
# All servers are assumed to exist in the given replication group.
# Requires PowerShell 3.0 and PowerShell DFS Replication (DFSR) Module
# available from Technet Downloads.
#-----------------------------------------------------------------------

# List of receiving server members (sites prefixes) to be added.
$array = "SITE01","SITE02","SITE03","SITE04","SITE05"

# Get replication group object.
$repGroup  = Get-DfsrReplicationGroup -Name "ReplicationGroupName"

# Get sending member object.
$sendMember = $repGroup | Get-DfsrMember -ComputerName SITE00

ForEach ($site in $array) {
  # Append suffix to site and write to console.
    $site = $site + "COMPANY"
    Write-Host "Adding connection for:" $site
    
  # Create receiving member object.  
    $receiveMember = $repGroup | Get-DfsrMember -ComputerName $site
      
  # Create connection.
    New-DfsrConnection -Member $receiveMember -SendingMember $sendMember -Enabled $true 
}
