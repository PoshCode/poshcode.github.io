$missingFld = @()
# Create an array of the full paths to the Clients folders
$clientPaths = (Get-ChildItem 'C:\Shared Drives\Clients' -Directory).FullName

# Step through each of the client folders...
ForEach ($clientFld in $clientPaths) {
    # Get the clientName by using Split-Path to get just the last part of the folder path
    $clientName = Split-Path $clientFld -Leaf
    # Return just the Name of all Subfolders in the current client's Audit folder
    $subFolders = (Get-ChildItem "$clientFld\Audit" -Directory).Name
    # If the $subFolders array doesn't contain '2015 Audit'...
    If ($subFolders -notcontains '2015 Audit') {
        # ...then add the client name to $missingFld
        $missingFld += $clientName
    }
}

# Then output the $missingFld to whatever filepath specified in $outputFilePath
$outputFilePath = 'C:\MissingAuditFolders.txt'
$missingFld | Out-File $outputFilePath -Force
