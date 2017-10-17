function Open-Solution([string]$path = ".") {
  $sln_files = Get-ChildItem $path -Include *.sln -Recurse
  if($sln_files -eq $null) {
    Write-Host "No Solution file found"
    return
  }
  if($sln_files.Count) { # There is more than one
    do {
      Write-Host "Please select file (or Ctrl+C to quit)"
      for($i=0;$i -lt $sln_files.Count;$i=$i+1) { Write-Host "($i) - $($sln_files[$i])" }
      $idx = Read-Host
      $sln = $sln_files[$idx]
    }until($sln)
  }
  else { $sln = $sln_files }
  Invoke-Item $sln
}
