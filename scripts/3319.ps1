function Get-ProfilesList {
  $hive = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

  gci $hive | % -b {$prof = @()} -p {$dest = "" | select UserName, Sid, ProfilePath
    $dest.Sid = $_.PSChildName
    $dest.ProfilePath = (gp ($hive + "\" + $_.PSChildName)).ProfileImagePath
    $dest.UserName = Split-Path $dest.ProfilePath -leaf
    $prof += $dest
  } -end {$prof | ft -a}
}
