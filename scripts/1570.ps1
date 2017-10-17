[CmdletBinding(DefaultParameterSetName='DefaultParameter')]
param(
    [Parameter(ValueFromPipeline=$true)]
    [System.Management.Automation.PSObject]
    ${InputObject},

    [Parameter(ParameterSetName='DefaultParameter', Position=0, Mandatory=$true)]
    [System.String[]]
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
    ${Index}
)
begin
{
   try {
      $propHash = @()
      foreach($Prop in $Property) {
         $propHash += @(@{Name=$Prop; Expression=$(iex "{if(`$_.'$Prop' -is [Array]){ ""{`$(`$_.'$Prop' -join "", "")}"" }else{ `$_.'$Prop' } }")})
      }
      $PSBoundParameters['Property'] = $propHash
     
      $outBuffer = $null
      if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
      {
         $PSBoundParameters['OutBuffer'] = 1
      }
      $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Select-Object', [System.Management.Automation.CommandTypes]::Cmdlet)
      $scriptCmd = {& $wrappedCmd @PSBoundParameters }
      $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
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


