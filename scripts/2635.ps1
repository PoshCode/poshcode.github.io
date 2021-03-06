function Find-Application {
[CmdletBinding()]
   param( [string]$Name )
begin {
   [String[]]$Path = (Get-Content Env:Path).Split(";") |
                     ForEach-Object { 
                        if($_ -match "%.*?%"){
                           $expansion = Get-Content ($_ -replace '.*%(.*?)%.*','Env:$1')
                           ($_ -replace "%.*?%", $expansion).ToLower().Trim("\","/") + "\"
                        } else {
                           $_.ToLower().Trim("\","/") + "\"
                        }
                     }
}
end {
   ## First, try Get-Command (which searches the PATH) but suppress command not found error
   $eap, $ErrorActionPreference = $ErrorActionPreference, "SilentlyContinue"
   $command = Get-Command $Name -Type Application
   $ErrorActionPreference = $eap

   ## Second, try HKLM App Paths (which are used by ShellExecute)
   if(!$command) {
      $AppPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"
      if(Test-Path $AppPaths\$Name) {
         $default = (Get-ItemProperty $AppPaths\$Name)."(default)"
         if($default) {
            $command = Get-Command $default.Trim("`"'") # | Select -First 1
         }
      }
      if(!$command) {
         $Name = [IO.Path]::GetFileNameWithoutExtension($Name)
         if(Test-Path $AppPaths\$Name) {
            $default = (Get-ItemProperty $AppPaths\$Name)."(default)"
            if($default) {
               $command = Get-Command $default.Trim("`"'") # | Select -First 1
            }
         }
      }
      if(!$command){
         if(Test-Path "$AppPaths\$Name.exe") {
            $default = (Get-ItemProperty "$AppPaths\$Name.exe")."(default)"
            if($default) {
               $command = Get-Command $default.Trim("`"'") # | Select -First 1
            }
         }
      }
   }

   ## Third, try Windows Search against the start menu as a last resort
   if(!$command) {
      $Name = [IO.Path]::GetFileNameWithoutExtension($Name)
      $query =@"
SELECT System.ItemName, System.Link.TargetParsingPath FROM SystemIndex
WHERE  System.Kind = 'link' AND System.ItemPathDisplay like '%Start Menu%' AND
       ( System.Link.TargetParsingPath like '%${Name}.exe' OR System.ItemName like '%${Name}%' )
"@

      $Connection = New-Object System.Data.OleDb.OleDbConnection "Provider=Search.CollatorDSO;Extended Properties='Application=Windows';"
      $Adapter = New-Object System.Data.OleDb.OleDbDataAdapter (New-Object System.Data.OleDb.OleDbCommand $Query, $Connection)
      $DataSet = New-Object System.Data.DataSet
      $Connection.Open()
      if($Adapter.Fill($DataSet)) {
         $command = $DataSet.Tables[0] | ForEach-Object { 
                     Get-Command $_["System.Link.TargetParsingPath"] | 
                     Add-Member -Type NoteProperty -Name Shortcut -Value $_["System.ItemName"] -Passthru 
                  }
      }
      $Connection.Close()
   }

   ## Now, make sure that we output everything in the right order: 
   ## Get-Command, Keep the Shortcut value if there is one
   ## Then sort by the position in the PATH and make sure if it's not in there, it comes last
   ## Finally, sort LONG shortcut names after SHORT ones ...
   ##  .... because we do partial matching on them, so the LONGER one matches less precisely.
   $( foreach($cmd in $command) {
         Get-Command $cmd.Path -ErrorAction SilentlyContinue -Type Application | ForEach-Object {
            Add-Member -InputObject $_ -Type NoteProperty -Name Shortcut -Value $cmd.ShortCut -Passthru
         }
      }
   ) | Sort-Object Definition -Unique | Sort-Object {
         $index = [array]::IndexOf( $Path, [IO.Path]::GetDirectoryName($_.Path).ToLower().Trim("\","/") + "\" )
         if($index -lt 0) { $index = 1e5 } else { $index *= 100 }
         if($_.Shortcut) {
            $index += $_.Shortcut.Length
         }
         $index
      }
}

#.Synopsis 
#    Finds an executable by searching the path, using Get-Command, the AppPaths registry key, and Windows Search.
#.Example
#    Get-App Notepad
#       Finds notepad.exe using Get-Command
#.Example
#    Get-App pbrush
#       Finds mspaint.exe using the "App Paths" registry key
#.Example
#    &(Get-App WinWord)
#       Finds, and launches, Word (if it's installed) using the "App Paths" registry key
#.Example
#    Get-App "Windows PowerShell"
#       Finds PowerShell.exe by searching the Start menu for the link
#.Notes
## Revision History (latest first)
## 2.1 - Fix output and sorting so that:
##     - We output more than one if there is more than one, 
##     - But sort them by path and accuracy
## 2.0 - Add Windows Search
## 1.1 - strip quotes from results...
## 1.0 - initial release
}
