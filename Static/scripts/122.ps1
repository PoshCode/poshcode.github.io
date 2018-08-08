## This ought to be the same as Get-Command, except...
## it will output the commands in the actual order they would be used by the shell
function which( [string]$command ) {
   $Script:ErrorActionPreference = "SilentlyContinue"
   Get-Command $command -commandType Alias 
   Get-Command $command -commandType Function
   Get-Command $command -commandType Cmdlet
   Get-Command $command -commandType Script
   Get-Command $command -commandType Application
   Get-Command $command -commandType ExternalScript
}
