#function get-help() {
cmdlet -DefaultParameterSet AllUsersView `

param(
   [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
   [System.String]
   $Name,

   [ValidateSet("Alias","Cmdlet","Provider","General","FAQ","Glossary","HelpFile","All")]
   [System.String[]]
   $Category,

   [System.String[]]
   $Component,

   [System.String[]]
   $Functionality,

   [System.String[]]
   $Role,

   [Parameter(ParameterSetName="DetailedView")]
   [Switch]
   $Detailed,

   [Parameter(ParameterSetName="AllUsersView")]
   [Switch]
   $Full,

   [Parameter(ParameterSetName="Examples")]
   [Switch]
   $Examples,

   [Parameter(ParameterSetName="Parameters")]
   [System.String]
   $Parameter
)
Begin
{ 
   $wrappedCmdlet = $ExecutionContext.InvokeCommand.GetCmdlet('Get-Help')
   $scriptCmd = { 
      Microsoft.PowerShell.Core\Get-Help @CommandLineParameters -EA "SilentlyContinue"
   }
   $steppablePipeline = $scriptCmd.GetSteppablePipeline()
   $steppablePipeline.Begin($PSCmdlet)
}

Process
{  
   $out = $steppablePipeline.Process($_) 

      if(!$out) { 
         (get-command $Name).ParameterSets | format-list Name, @{l="Definition"; e={"$_"}} 
      }  
}

End
{  $steppablePipeline.End() }

#}
