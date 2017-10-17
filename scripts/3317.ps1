$arr = @()
$key = "HKLM:\SOFTWARE\Classes\CLSID"

foreach ($i in (gci $key)) {
  $des = $key + "\" + $i.PSChildName + "\ProgID"
  Write-Progress "Dumping. Please, standby..." $des

  foreach ($a in (gp -ea 0 $des)."(default)") {
    $arr += $a
  }
}

[array]::Sort([array]$arr)
$arr | Out-File -file C:\logs\COMnames.txt -enc UTF8
