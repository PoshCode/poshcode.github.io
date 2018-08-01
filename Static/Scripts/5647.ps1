function Get-FolderSize {
$location = $args[0]
Write-Host "Directory to Scan:"$location
$value = "{0:N2}" -f ((Get-ChildItem -recurse $location | Measure-Object -property length -sum).Sum / 1MB)
Write-Host "Used Storage for Directory:"$value" MB"
}
