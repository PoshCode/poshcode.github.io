Get-ChildItem Registry::HKCR\CLSID | ForEach-Object {
  $x = (Get-ItemProperty 'Registry::HKCR\Component Categories\*' |
  Where-Object {$_ -match 'antivirus'}).PSChildName
}{
  if ((Get-ChildItem "$($_.PSPath)\Implemented Categories" -ea 0).PSChildName -eq $x) {
    Split-Path (Get-ItemProperty "$($_.PSPath)\InprocServer32").'(default)'
    break
  }
}
