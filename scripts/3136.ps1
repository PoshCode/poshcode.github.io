<#
.SYNOPSIS
 A very simple module to retrieve the Set-StrictMode setting of the session.
.DESCRIPTION
This procedure is necessary as there is, apparently, no PowerShell variable 
for this and enables the user setting to be returned to its original state 
after possibly being changed within a script.
The various values returned will be Version 1, Version 2, or Off.
#>
function Get-StrictMode {
   try {
      $version = '2'
      $z = "2 * $nil"       #V2 will catch this one.
      $version = '1'
      $z = 2 * $nil         #V1 will catch this.
      Write-Host "StrictMode: Off"
   }
   catch {
      Write-Host "StrictMode: Version $version"
   }
}
