#function Get-InstalledPrinters {
  Add-Type -Assembly System.Drawing
  $count = [Drawing.Printing.PrinterSettings]::InstalledPrinters
  
  if ($count -eq $null) {
    Write-Host No printers has been installed on this computer. -fo Yellow
  }
  else {$count}
#}
