## Which.ps1 - aka Get-Command
###################################################################################################
## This ought to be the same as Get-Command, except...
## This Which function will output the commands ...
## in the actual order they would be used by the shell
##################################################################################################
## Revision History
## 1.0 - initial release just sorted the Get-Command output by CommandType
## 2.0 - rewritten to take into account the order of commands in the PATH environment variable
##################################################################################################
function Get-Command([string]$command) {
begin { $Script:ErrorActionPreference = "SilentlyContinue" }
process {
if(!$_) { $_ = $command }
Microsoft.PowerShell.Core\Get-Command $_ |
   sort {
      if($_.CommandType -match "ExternalScript|Application") {
         1000 + [array]::IndexOf( (Get-Content Env:Path).Split(";"), [IO.Path]::GetDirectoryName($_.Definition) )
      } else {
         [int]$_.CommandType
      }
   }
}
}

