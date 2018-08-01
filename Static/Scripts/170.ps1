
## Get-App
## Attempt to resolve the path to an executable using Get-Command and the AppPaths registry key
##################################################################################################
## Example Usage:
##    Get-App Notepad
##       Finds notepad.exe using Get-Command
##    Get-App pbrush
##       Finds mspaint.exe using the "App Paths" registry key
##    &(Get-App WinWord)
##       Finds, and launches, Word (if it's installed) using the "App Paths" registry key
##################################################################################################
## Revision History
## 1.0 - initial release
##################################################################################################
function Get-App {
   param( [string]$cmd )
   $eap = $ErrorActionPreference
   $ErrorActionPreference = "SilentlyContinue"
   Get-Command $cmd
   if(!$?) {
      $AppPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"
      if(!(Test-Path $AppPaths\$cmd)) {
         $cmd = [IO.Path]::GetFileNameWithoutExtension($cmd)
         if(!(Test-Path $AppPaths\$cmd)){
            $cmd += ".exe"
         }
      }
      if(Test-Path $AppPaths\$cmd) {
         Get-Command (Get-ItemProperty $AppPaths\$cmd)."(default)"
      }
   }
}

