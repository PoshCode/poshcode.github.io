## An example of how to make a custom object with strongly-typed properties, custom enumeration values, and custom validators, etc.

function Export-CustomProperty {
param(
   [Parameter(ValueFromPipeline=$true)]
   [PSCustomObject]$Object
)
process {
   foreach($property in Get-Member Get_*,Set_* -Input $Object -Type Methods | Group-Object { $_.Name.Split("_",2)[1] }) {
      $GetAccessor = $SetAccessor = {}
      foreach($accessor in $property.Group) {
         switch($accessor.Name.Split("_")[0]) {
            "Get" {
               $GetAccessor = [ScriptBlock]::Create('$this.' + $accessor.Name + '()')
            }
            "Set" {
               $SetAccessor = [ScriptBlock]::Create('try { $this.' + $accessor.Name + '( $args ) } catch { throw $_.Exception.Message.Split(":",2)[1].trim('' "'') }')
            }
         }
      }
         
      Add-Member -Input $Object -Type ScriptProperty -Name $Property.Name -Value $GetAccessor $SetAccessor
   }
   Write-Output $Object
}
}


## USAGE:

$customThing = New-Module -AsCustomObject {

   ## The FooBar property: a variable, two accessor methods and later, a ScriptProperty.
   [string]$FooBar = 'foo'
   [string[]]$FooBarValues = 'foo','bar'
   
   function Get_FooBar { $FooBar }
   
   function Set_FooBar { 
      param([string]$value)
      if($FooBarValues -notcontains $Value) {
         throw "You can't set FooBar to '$value', valid values are $($FooBarValues -join ', ').";
      }
      $script:FooBar = $value
   }
   
   ## The Enabled property: just a strongly-typed variable
   [bool]$Enabled = $False
   
  
   ## The UserName property: a variable, two accessor methods (and a validation method) and later, a ScriptProperty.
   [String]$UserName = $Env:UserName

   function Test-ADUser {
      [CmdletBinding()]
      param([string]$UserName)
      $ads = New-Object System.DirectoryServices.DirectorySearcher([ADSI]'')
      $ads.filter = "(&(objectClass=Person)(samAccountName=$UserName))"
      return [bool]$ads.FindOne()
   }

   function Get_UserName { $UserName }

   function Set_UserName { 
      param([string]$value)
      if(!(Test-ADUser $Value)) {
         throw "You can't set UserName to '$value', that user doesn't exist.";
      }
      $script:UserName = $value
   }

   Export-ModuleMember -Function Get_*,Set_* -Variable Enabled

} | Export-CustomProperty


#### Sample Validation Output:
##############################################################################
#  C:\PS> $customThing.UserName = 'Nobody'
#  
#  Exception setting "UserName": "You can't set UserName to 'Nobody', that user doesn't exist."
#  At line:1 char:6
#  + $customThing. <<<< UserName = 'Nobody'
#      + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
#      + FullyQualifiedErrorId : PropertyAssignmentException
#   
#  
#  C:\PS> $customThing.FooBar = 'foobar'
#  
#  Exception setting "FooBar": "You can't set FooBar to 'foobar', valid values are foo, bar."
#  At line:1 char:6
#  + $customThing. <<<< FooBar = 'foobar'
#      + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
#      + FullyQualifiedErrorId : PropertyAssignmentException
#  
#  
#  C:\PS> $customThing.Enabled = "what"
#  
#  Cannot convert value "System.String" to type "System.Boolean", parameters of this type only accept booleans or numbers, use $true, $false, 1 or 0 instead.
#  At line:1 char:6
#  + $customThing. <<<< Enabled = "what"
#      + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
#   + FullyQualifiedErrorId : PropertyAssignmentException
