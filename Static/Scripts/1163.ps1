$DriveLetter = "D:"
$MaxShrink = 0.30	# 0.30 equals 30%
$MinShrink = 0.20	# 0.20 equals 20%
$FileLocation = $env:Temp
$FileName4DiskPart = "Shrink.txt"

$DiskDrive = GWMI -CL Win32_LogicalDisk | Where {$_.DeviceId -Eq "$DriveLetter"}
$DriveSize = ($DiskDrive.Size /1GB)
$DriveSize = [int]$DriveSize

$DesiredShrink = [int]($DriveSize * $MaxShrink)
$MinimumShrink = [int]($DriveSize * $MinShrink)

#Write-Host DiskSize $DriveSize GB
#Write-Host DesiredShrink $DesiredShrink GB
#Write-Host MinimumShrink $MinimumShrink GB

Write "Select volume $DriveLetter" |Out-file $FileLocation\$FileName4DiskPart -encoding ASCII
Write "shrink desired=$DesiredShrink minimum=$MinimumShrink" |Out-file $FileLocation\$FileName4DiskPart -append -encoding ASCII

&cmd " /c diskpart" " /s $FileLocation\$FileName4DiskPart"
