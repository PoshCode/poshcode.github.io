function Start-Cassini([string]$physical_path=((@(Coalesce-Args (Find-File Global.asax).DirectoryName "."))[0]), [int]$port=12372, [switch]$dontOpenBrowser) {
  $serverLocation = Resolve-Path "C:\Program Files (x86)\Common Files\Microsoft Shared\DevServer\10.0\WebDev.WebServer40.EXE";
  $full_app_path = Resolve-Path $physical_path
  $url = "http://localhost:$port"
  &($serverLocation.Path) /port:$port /path:"""$($full_app_path.Path)"""
  Write-Host "Started $($full_app_path.Path) on $url"
  Write-Host "Remember you can kill processes with kill -name WebDev*"
  if($dontOpenBrowser -eq $false) {
    [System.Diagnostics.Process]::Start($url)
  }
}
