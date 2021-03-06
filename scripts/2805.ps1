function Get-LocalGroupMember {
param( 
   # The name of the local group to retrieve members of
   [Parameter(Position=0,Mandatory=$true)]
   [String]$GroupName = "administrators",

   # A filter for the user name(s)
   [Parameter(Position=1)]
   [String]$UserName = "*",

   # The computer to query (defaults to the local machine)
   [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
   [Alias("CN")]
   [String[]]$ComputerName = ${Env:ComputerName},
   
   # If set, returns only local computer accounts
   [Switch]$LocalAccountsOnly,

   # If set, returns only domain accounts
   [Switch]$DomainAccountsOnly
)
process {
   foreach($cName in $ComputerName) {
      $Group = [System.DirectoryServices.DirectoryEntry][ADSI]"WinNT://$cName/$GroupName,group"
      
      try{ $Null = $Group.PSBase.InvokeGet("Name") } catch {
          
         switch -regex (($Exception = $_.Exception.InnerException).Message) {
            "Access Denied" { 
               Write-Error -Exception $Exception -Category PermissionDenied -CategoryTargetName $cName -CategoryTargetType Computer -TargetObject ([ADSI]"WinNT://$cName") -CategoryReason $Exception.Message -RecommendedAction "Check your credentials and try again"
            }
            "group name|local group" {
               Write-Error -Exception $Exception -Category ObjectNotFound -CategoryTargetName $GroupName -CategoryTargetType Group -TargetObject ([ADSI]"WinNT://$cName") -CategoryReason $Exception.Message -RecommendedAction "Check the spelling of the group name and try again"
            }
            "network path" {
               Write-Error -Exception $Exception -Category ResourceUnavailable -CategoryTargetName $cName -CategoryTargetType Computer -TargetObject ([ADSI]"WinNT://$cName") -CategoryReason $Exception.Message -RecommendedAction "Verify the computer name is correctly and that it's turned on and network accessible"
            }
            default {
               Write-Error -Exception $Exception -Category NotSpecified -CategoryTargetName $cName -CategoryTargetType Computer -TargetObject ([ADSI]"WinNT://$cName") -CategoryReason $Exception.Message
            }
         }
         continue
      }

      $Group.Members() | 
         ForEach-Object { 
            [System.DirectoryServices.DirectoryEntry]$_ | 
            ## Overwrite or Create an NTAccountName property
            Add-Member ScriptProperty NTAccountName {$this.Path.Replace("WinNT://","").Replace("/","\")} -force -passthru |
            ## Create a distinguishedName, because that displays by default, but is empty
            Add-Member AliasProperty distinguishedName NTAccountName -force -passthru |
            ## Add a PSComputerName
            Add-Member NoteProperty PSComputerName $cName -force -passthru |
            ## Add IsLocalAccount
            Add-Member ScriptProperty IsLocalAccount {$this.Path -match "/$($this.PSComputerName)/"} -force -passthru
         } | 
         Where-Object { 
            ($_.Name -like $UserName) -And
            (!$LocalAccountsOnly  -or ($_.Path -match "/${ComputerName}/")) -And
            (!$DomainAccountsOnly -or ($_.Path -notmatch "/${ComputerName}/") )
         }
   }
}
<#
.Synopsis 
   Lists the members of the specified local group 
.Description
   List all members of local Groups from a specified computer (eg: administrators, power users, backup operators, etc.)
.Example
   Get-LocalGroupMember administrators -LocalAccount
   
   Retrieves all the local computer accounts that are members of the administrators group on the local machine
.Example
   Get-LocalGroupMember "Power Users"
   
   Retrieves all the accounts that are members of the Power Users group
.Example
   Get-LocalGroupMember administrators Admin*
   
   Retrieves all the administrators who's name starts with "admin"
.Example
   Get-LocalGroupMember administrators -ComputerName Server1, Server2 | ft PSComputerName, Name, IsLocalAccount
   
   Retrieves administrators from several computers and displays specific information about them
.Notes
   Copyright (c) 2010 Joel Bennett

   Permission is hereby granted, free of charge, to any person obtaining a copy 
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights 
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
   copies of the Software, and to permit persons to whom the Software is 
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in 
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
   SOFTWARE.
   *****************************************************************************
   NOTE: YOU MAY *ALSO* DISTRIBUTE THIS FILE UNDER ANY OF THE FOLLOWING...
   PERMISSIVE LICENSES:
   BSD:	 http://www.opensource.org/licenses/bsd-license.php
   MIT:   http://www.opensource.org/licenses/mit-license.html
   Ms-PL: http://www.opensource.org/licenses/ms-pl.html
   RECIPROCAL LICENSES:
   Ms-RL: http://www.opensource.org/licenses/ms-rl.html
   GPL 2: http://www.gnu.org/copyleft/gpl.html
   *****************************************************************************
   LASTLY: THIS IS NOT LICENSED UNDER GPL v3 (although the above are compatible)
#>
}


