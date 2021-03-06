<#
  This is a proxy function enhancing Select-Object by adding the
  ability to use subproperties in the Property parameters.
  
  For example:
  Set-Process | Select-Object ProcessName, StartTime.DayOfWeek
  
  This is the only changed behavior (properties with dots
  get evaluated as expressions) - everything else stays intact.
  
  For more information see:
http://dmitrysotnikov.wordpress.com/2010/01/25/select-object-with-subproperties
#>

function Select-Object {
[CmdletBinding(DefaultParameterSetName='DefaultParameter')]
param(
  [Parameter(ValueFromPipeline=$true)]
  [System.Management.Automation.PSObject]
  ${InputObject},

  [Parameter(ParameterSetName='DefaultParameter', Position=0)]
  [System.Object[]]
  ${Property},

  [Parameter(ParameterSetName='DefaultParameter')]
  [System.String[]]
  ${ExcludeProperty},

  [Parameter(ParameterSetName='DefaultParameter')]
  [System.String]
  ${ExpandProperty},

  [Switch]
  ${Unique},

  [Parameter(ParameterSetName='DefaultParameter')]
  [ValidateRange(0, 2147483647)]
  [System.Int32]
  ${Last},

  [Parameter(ParameterSetName='DefaultParameter')]
  [ValidateRange(0, 2147483647)]
  [System.Int32]
  ${First},

  [Parameter(ParameterSetName='DefaultParameter')]
  [ValidateRange(0, 2147483647)]
  [System.Int32]
  ${Skip},

  [Parameter(ParameterSetName='IndexParameter')]
  [ValidateRange(0, 2147483647)]
  [System.Int32[]]
  ${Index})

begin
{
 try {
     $outBuffer = $null
     if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
     {
         $PSBoundParameters['OutBuffer'] = 1
     }
     
     #region: Dmitry Sotnikov: substitute dotted properties with expressions
     if ($Property -ne $null) {
      # Iterate through properties and substitute those with dots
      $NewProperty = @()
      foreach ( $prop in $Property ) {
       if ($prop.GetType().Name -eq 'String') {
        if ($prop.Contains('.')) {
         [String] $exp = '$_.' + $prop
         $prop = @{Name=$prop; Expression = {Invoke-Expression ($exp)}}
        }
       }
       $NewProperty += $prop
      }
      $PSBoundParameters['Property'] = $NewProperty
     }
     #endregion
     
     $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Select-Object', 
         [System.Management.Automation.CommandTypes]::Cmdlet)
     $scriptCmd = {& $wrappedCmd @PSBoundParameters }
     $steppablePipeline = 
         $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
     $steppablePipeline.Begin($PSCmdlet)
 } catch {
     throw
 }
}

process
{
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
}
<#

.ForwardHelpTargetName Select-Object
.ForwardHelpCategory Cmdlet

#>
}
