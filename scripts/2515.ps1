function Get-VMHostLunLatency {
  param([parameter(Mandatory=$true, ValueFromPipeline=$true)] $VMHost)

  process {
    $luns = Get-ScsiLun -VmHost $VMHost
    $DiskStats = $VMHost |
      Get-Stat -stat disk.totalreadlatency.average,disk.totalwritelatency.average -maxsamples 1 -realtime 
    foreach ($lun in $luns) {
      $Stats = $DiskStats  |
        Where { $_.Instance -eq $Lun.CanonicalName }
      if ($stats.length -ne $null) {
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name VMHost -Value $VMHost.Name
        $obj | Add-Member -MemberType NoteProperty -Name Lun -Value $lun.CanonicalName
        $obj | Add-Member -MemberType NoteProperty -Name ReadLatency -Value ($stats[0].Value)
        $obj | Add-Member -MemberType NoteProperty -Name WriteLatency -Value ($stats[1].Value)
        Write-Output $obj
      }
    }
  }
}
