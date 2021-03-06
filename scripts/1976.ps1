function Set-AssemblyBindLogging {
#.Synopsis
#  Enable or disable Assembly Bind logging for the machine
#.Parameter EnableLogging
#  Whether or not to enable logging. Accepts partial matching of Enable/Disable or True/False or even 1/0 ... 
#.Parameter LogPath
#  The location of the folder you want to save fusion logs to. Will be created if it does not already exist
#  NOTE: If you are DISABLING logging, this folder will be DELETED (if it is empty).
[CmdletBinding()]
   param( 
      [Parameter(Mandatory=$true)]
      #[ValidateSet("Enable","Disable","True","False","0","1")]
      [string]$EnableLogging
   ,
      $LogPath = "C:\Logs\Fusion" 
   )

   foreach($RegistryRoot in "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Fusion","HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Fusion") {
      switch -regex ($EnableLogging) {
         "En?a?b?l?e?|Tr?u?e?|1" {
            mkdir $LogPath -Force -EA Stop

            Set-ItemProperty REGISTRY::$RegistryRoot LogPath $LogPath
            foreach($switch in "LogFailures","ForceLog","LogResourceBinds") {
               Set-ItemProperty REGISTRY::$RegistryRoot $switch 1 -Type DWord
            }
         }
         "Di?s?a?b?l?e?|Fa?l?s?e?|0" {
            rmdir $LogPath
            foreach($switch in "LogPath","LogFailures","ForceLog","LogResourceBinds") {
               Remove-ItemProperty $switch
            }
         }
         default {
            throw "Couldn't convert '$EnableLogging' to a valid value. Valid values are: Enable or Disable, True or False, 1 or 0."
         }
      }
   }  
}




