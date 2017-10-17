$Drive = Read-Host "Path to Folders"
Write-Host "This will delete all empty folders in this directory!"
$a = Get-ChildItem $drive -recurse | Where-Object {$_.PSIsContainer -eq $True}
$a | Where-Object {$_.GetFiles().Count -lt 1} | Select-Object FullName | ForEach-Object {remove-item $_.fullname -recurse} 
Write-Host "All Done!"
