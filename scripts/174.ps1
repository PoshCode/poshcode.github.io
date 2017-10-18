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
## 1.1 - strip quotes from results...
##     - NOTE: should be used with the "which" script to return the correct item in the case 
##       where you're calling an app that would show up in the normal Get-Command...
##       http://powershellcentral.com/scripts/173 
##################################################################################################
#function Get-App {
   param( [string]$cmd )

   $command = $null
   $eap = $ErrorActionPreference
   $ErrorActionPreference = "SilentlyContinue"
   $command = Get-Command $cmd | Select -First 1
   $ErrorActionPreference = $eap
  
   if($command -eq $null) {
      $AppPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"
      if(!(Test-Path $AppPaths\$cmd)) {
         $cmd = [IO.Path]::GetFileNameWithoutExtension($cmd)
         if(!(Test-Path $AppPaths\$cmd)){
            $cmd += ".exe"
         }
      }
      if(Test-Path $AppPaths\$cmd) {
         $default = (Get-ItemProperty $AppPaths\$cmd)."(default)"
         if($default) {
            Get-Command $default.Trim("""'")
         }
      }
   }
#}

