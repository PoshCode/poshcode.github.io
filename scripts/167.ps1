## New-Script function
## Creates a new script from the most recent commands in history
##################################################################################################
## Example Usage:
##    New-Script ScriptName 4
##        creates a script from the most recent four commands 
##    New-Script ScriptName -id 10,11,12,14
##        creates a script from the specified commands in history
##    New-Script Clipboard 2
##        sends the most recent two commands to the clipboard
##################################################################################################
## As a tip, I use a prompt function something like this to get the ID into the prompt:
##
## function prompt {
##   return "`[{0}]: " -f ((get-history -count 1).Id + 1)
## }
##################################################################################################

#function New-Script {
param( 
   [string]$script=(Read-Host "A name for your script"),
   [int]$count=1, 
   [int]$id=((Get-History -count 1| Select Id).Id)
)

if($script -eq "clipboard") {
   if( @(Get-PSSnapin -Name "pscx").Count ) {
      Get-History -count $count -id $id | &{process{ $_.CommandLine }} | out-clipboard
   }elseif(@(gcm clip.exe).Count) {
      Get-History -count $count -id $id | &{process{ $_.CommandLine }} | clip
   }
} else {
   # default to putting it in my "Windows PowerShell\scripts" folder which I have in my path...
   $folder = Split-Path $script
   if(!$folder) {
      $folder = Join-Path (Split-Path $Profile) "Scripts"
   }
   if(!(Test-Path $folder)) { 
      Throw (new-object System.IO.DirectoryNotFoundException "Cannot find path '$folder' because it does not exist.")
   }
   # add the ps1 extension if it's not already there ...
   $file = Join-Path $folder (Split-Path $script -leaf)
   if(!(([IO.FileInfo]$file).Extension)) { 
      $file = "$file.ps1"
   }

   Get-History -count $count -id $id | &{process{ $_.CommandLine }} | set-content $file
}
#}
