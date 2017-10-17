﻿#Requires -Version 2.0

## Automatically load functions from scripts on-demand, instead of having to dot-source them ahead of time, or reparse them from the script every time.
## To use:
## 1) Create a function. To be 100% compatible, it should specify pipeline arguments
## For example:
<#
function Skip-Object {
param( 
   [int]$First = 0, [int]$Last = 0, [int]$Every = 0, [int]$UpTo = 0,  
   [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
   $InputObject
)
begin {
   if($Last) {
      $Queue = new-object System.Collections.Queue $Last
   }
   $e = $every; $UpTo++; $u = 0
}
process {
   $InputObject | where { --$First -lt 0 } | 
   foreach {
      if($Last) {
         $Queue.EnQueue($_)
         if($Queue.Count -gt $Last) { $Queue.DeQueue() }
      } else { $_ }
   } |
   foreach { 
      if(!$UpTo) { $_ } elseif( --$u -le 0) {  $_; $U = $UpTo }
   } |
   foreach { 
      if($every -and (--$e -le 0)) {  $e = $every  } else { $_ } 
   }
}
}
#>
## 2) Put the function into a script with the same name (in our case: Skip-Object.ps1)
## 3) Put the script in your PATH ($env:Path) somewhere (i have a "scripts" folder I add to my path as part of my profile)
## 4) Dot-source this file, or include it as part of your profile
## 5) Add one line to your profile (or on the commandline):
<#
autoload Skip-Object
#>
## This tells us that you want to have that function loaded for you out of the script file if you ever try to use it.
## Now, you can just use the function:
## 1..10 | Skip-Object -first 2 -upto 2

function autoload {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
[string[]]$Name
)
begin {
   $xlr8r = [type]::gettype("System.Management.Automation.TypeAccelerators")
   if(!$xlr8r::Get["PSParser"]) {
      $xlr8r::Add( "PSParser", "System.Management.Automation.PSParser, System.Management.Automation, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" )
   }

   function global:Autoloaded {
      [CmdletBinding()]Param()
      DYNAMICPARAM {
         Write-Verbose "Autoloaded DynamicParam: $($MyInvocation.InvocationName)"
         ## Determine the Type name based on the alias used to invoke us
         ## Store the parameter set for use in the function later...
         $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
         # $command = Get-Command $MyInvocation.InvocationName -Type ExternalScript
         $externalScript = $ExecutionContext.InvokeCommand.GetCommand( $MyInvocation.InvocationName, [System.Management.Automation.CommandTypes]::ExternalScript )
         $parserrors = $null
         $prev = $null
         $script = $externalScript.ScriptContents
         [System.Management.Automation.PSToken[]]$tokens = [PSParser]::Tokenize( $script, [ref]$parserrors )
         [Array]::Reverse($tokens)
         
         ForEach($token in $tokens) {
            if($prev -and $token.Type -eq "Keyword" -and $token.Content -ieq "function" -and $prev.Content -eq $MyInvocation.InvocationName ) {
               $script = $script.Insert( $prev.Start, "global:" )
            }
            $prev = $token
         }
         Invoke-Expression $script | out-null
         $command = $ExecutionContext.InvokeCommand.GetCommand( $MyInvocation.InvocationName, [System.Management.Automation.CommandTypes]::Function )
         if(!$command) {
            throw "Something went wrong autoloading the $($MyInvocation.InvocationName) function. Function definition doesn't exist in script: $($externalScript.Path)"
         }
         foreach( $pkv in $command.Parameters.GetEnumerator() ){
            $parameter = $pkv.Value
            if( $parameter.Aliases -match "vb|db|ea|wa|ev|wv|ov|ob" ) { continue } 
            $param = new-object System.Management.Automation.RuntimeDefinedParameter( $parameter.Name, $parameter.ParameterType, $parameter.Attributes)
            $paramdictionary.Add($pkv.Key, $param)
         } 
         return $paramdictionary
      }#DynamicParam

      begin {
         ## Determine the Type name based on the alias used to invoke us
         Write-Verbose "Autoloaded Begin: $($MyInvocation.InvocationName)"
         Remove-Item Alias::$($MyInvocation.InvocationName)
         $command = $ExecutionContext.InvokeCommand.GetCommand( $MyInvocation.InvocationName, [System.Management.Automation.CommandTypes]::Function )
         $scriptCmd = {& $command @PSBoundParameters }

         $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
         $steppablePipeline.Begin($true)
      }
      process
      {
         Write-Verbose "Autoloaded Process: $($MyInvocation.InvocationName) ($_)"
         try {
            $steppablePipeline.Process($_)
         } catch {
            throw
         }
      }

      end
      {
         try {
            $steppablePipeline.End()
         } catch {
            throw
         }
         Write-Verbose "Autoloaded End: $($MyInvocation.InvocationName)"
      }
   }#AutoLoaded

}
process {
   foreach($function in $Name) {
      Write-Verbose "Set-Alias $function Autoloaded -Scope global"
      Set-Alias $function Autoloaded -Scope global
   }
}
}

