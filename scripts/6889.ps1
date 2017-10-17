Get-AppxProvisionedPackage -Online | Where {$_.PackageName -notlike “*store*” -and $_.PackageName -notlike “*calc*”} | Remove-AppxProvisionedPackage -Online
Get-AppxPackage | Where {$_.PackageFullName -notlike “*store*” -and $_.PackageFullName -notlike “*calc*”} | Remove-AppxPackage
