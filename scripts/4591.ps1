# TXT File containing the server hostnames or IPs you want to monitor
$monitoredServers = gc "C:\ServersToMonitor.txt"
# Directory containing the folder structure you want to compare
$referenceDirectory = "C:\CLEAN\"

# Get a list of files including the relative folder structure
$monitoredFiles = gci -Recurse $referenceDirectory | ? { ! $_.PSIsContainer } | % { $($_.FullName).replace("$referenceDirectory","") }

# Iterate through the list of servers
foreach ($server in $monitoredServers) {
    Write-Host "Checking: $server" -ForegroundColor GREEN
    
    # Iterate through  all the files found in the reference directory
    foreach ($file in $monitoredFiles) {
        Write-Host "Checking: \\$server\$file against $referenceDirectory\$file"
        
        # Check if the file exists and if it's contents match the reference files
        if ((!(Test-Path "\\$server\$file")) -or (Compare-Object $(gc "\\$server\$file") $(gc $referenceDirectory\$file))) {
               Write-Host "FILES DO NOT MATCH" -ForegroundColor RED
        }
    }
}
