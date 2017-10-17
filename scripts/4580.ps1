function Get-DriveFormatData {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true)]
    [ValidatePattern("[a-z]")]
    [Char]$DriveLetter
  )
  
  begin {
    function vol([Char]$dl) {
      try {
        $rk = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\MountedDevices')
        $rk.GetValueNames() | % {$hash = @{}}{
          $hash[$_] = [String]$rk.GetValue($_) -replace ' ', ''
        }{
          ($hash.GetEnumerator() | ? {$_.Value -eq $hash[('\DosDevices\' + $dl + ':')]}) | % {
            if ($_.Name -notmatch 'Dos') {$_.Name}
          }
        }
      }
      finally {
        if ($rk -ne $null) {$rk.Close()}
      }
    }
  }
  process {
    [IO.DriveInfo]::GetDrives() | % {$arr = @()}{
      $str = "" | select Drive, FileSystem, Size, Used, Avail, Use, Mounted, Label
      if ($_.Name -eq ($DriveLetter + ':\') -and $_.IsReady) {
        $str.Drive = $_.Name
        $str.FileSystem = $_.DriveFormat
        $str.Size = ("{0}Gb" -f [Math]::Round($_.TotalSize / 1Gb))
        $str.Used = ("{0:F2}Gb" -f (($_.TotalSize - $_.TotalFreeSpace) / 1Gb))
        $str.Avail = ("{0:F2}Gb" -f ($_.TotalFreeSpace / 1Gb))
        $str.Use = ("{0:F2}%" -f (($_.TotalSize - $_.TotalFreeSpace) * 100 / $_.TotalSize))
        $str.Mounted = (vol $_.Name[0])
        $str.Label = $_.VolumeLabel
        $arr += $str
      }
    }
  }
  end {
    $arr | ft -a
  }
}
