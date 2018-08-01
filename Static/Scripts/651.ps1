# Run-Defrag
# Defragments the targeted hard drives.
#
# Args:
#   $server: A target Server 2003 or 2008 system
#   $drive: An optional drive letter.  If this is blank then all 
#           drives are defragmented
#   $force: If this switch is set then a defrag will be forced
#           even if the drive is low on space
#
# Returns:
#   The result description for each drive.

function Run-Defrag {
  param([string]$server, [string]$drive, [switch]$force)

  [string]$query = 'Select * from Win32_Volume where DriveType = 3'

  if ($drive) {
    $query += " And DriveLetter LIKE '$drive%'"
  }

  $volumes = Get-WmiObject -Query $query -ComputerName $server

  foreach ($volume in $volumes) {
    Write-Host "Defragmenting $($volume.DriveLetter)..." -noNewLine
    $result = $volume.Defrag($force)
    switch ($result) {
      0  {Write-Host 'Success'}
      1  {Write-Host 'Access Denied'}
      2  {Write-Host 'Not Supported'}
      3  {Write-Host 'Volume Dirty Bit Set'}
      4  {Write-Host 'Not Enough Free Space'}
      5  {Write-Host 'Corrupt MFT Detected'}
      6  {Write-Host 'Call Cancelled'}
      7  {Write-Host 'Cancellation Request Requested Too Late'}
      8  {Write-Host 'Defrag In Progress'}
      9  {Write-Host 'Defrag Engine Unavailable'}
      10 {Write-Host 'Defrag Engine Error'}
      11 {Write-Host 'Unknown Error'}
    }
  }
}
