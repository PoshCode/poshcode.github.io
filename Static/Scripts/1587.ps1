#Requires -version 2.0
##This is just script-file nesting stuff, so that you can call the SCRIPT, and after it defines the global function, it will call it.
param ( 
   [Parameter(Position=1,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
   $Name
,
   [Parameter(Position=2,ValueFromPipelineByPropertyName=$true,Mandatory=$false)]
   $ModuleName
,
   [switch]$ShowCommon
, 
   [switch]$Full
,
   [switch]$Passthru
)


function global:Get-Parameter {
#.Synopsis 
# Enumerates the parameters of one or more commands
#.Description
# Lists all the parameters of a command, by ParameterSet, including their aliases, type, etc.
#
# By default, formats the output to tables grouped by command and parameter set
#.Example
#  Get-Command Select-Xml | Get-Parameter
#.Example
#  Get-Parameter Select-Xml

param ( 
   [Parameter(Position=1,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
   $Name
,
   [Parameter(Position=2,ValueFromPipelineByPropertyName=$true,Mandatory=$false)]
   $ModuleName
,
   [switch]$ShowCommon
, 
   [switch]$Full
,
   [switch]$Passthru
)
   if($Passthru) {
      $PSBoundParameters.Remove("Passthru")
      Get-ParameterRaw @PSBoundParameters
   } elseif(!$Full) {
      Get-ParameterRaw @PSBoundParameters | Format-Table Name, Type, ParameterSet, Mandatory -GroupBy @{n="Command";e={"{0}`n   Set:     {1}" -f $_.Command,$_.ParameterSet}}
   } else {
      Get-ParameterRaw @PSBoundParameters | Format-Table Name, Aliases, Type, Mandatory, Pipeline, PipelineByName, Position -GroupBy @{n="Command";e={"{0}`n   Set:     {1}" -f $_.Command,$_.ParameterSet}}
   }
}

## This is Hal's original script (modified a lot)
Function global:Get-ParameterRaw {
param ( 
   [Parameter(Position=1,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
   $Name
,
   [Parameter(Position=2,ValueFromPipelineByPropertyName=$true,Mandatory=$false)]
   $ModuleName
,
   [switch]$ShowCommon
, 
   [switch]$Full
)
BEGIN {
   $PropertySet = @( "Name", 
                     "Aliases", 
                     @{n="Type";e={$_.ParameterType.Name}}, 
                     @{n="ParameterSet";e={$paramset.Name}},
                     @{n="Command";e={"{0}/{1}" -f $(if($command.ModuleName){$command.ModuleName}else{$Command.CommandType.ToString()+":"}),$command.Name}}
                     @{n="Mandatory";e={$_.IsMandatory}}, 
                     @{n="Pipeline";e={$_.ValueFromPipeline}},
                     @{n="PipelineByName";e={$_.ValueFromPipelineByPropertyName}},
                     "Position"
                  )
   if(!$Full) {
      $PropertySet = $PropertySet[0,2,3,4,5]
   }
}
PROCESS{
   if($ModuleName) { $Name = "$ModuleName\$Name" }
   foreach($command in Get-Command $Name -ErrorAction silentlycontinue) {
      # resolve aliases (an alias can point to another alias)
      while ($command.CommandType -eq "Alias") {
         $command = @(Get-Command ($command.definition))[0]
      }
      if (-not $command) { continue }

      foreach ($paramset in $command.ParameterSets){
         foreach ($param in $paramset.Parameters) {
            if(!$ShowCommon -and ($param.aliases -match "vb|db|ea|wa|ev|wv|ov|ob|wi|cf")) { continue }
            
            $parameter = $param | Select-Object $PropertySet

            if($parameter.ParameterSet -eq "__AllParameterSets") { $parameter.ParameterSet = "Default" }
            if($Full -and $parameter.Position -lt 0) {$parameter.Position = $null}
            Write-Output $parameter
         }
      }
   }
}
}

# This is nested stuff, so that you can call the SCRIPT, and after it defines the global function, we will call that.
Get-Parameter @PSBoundParameters

