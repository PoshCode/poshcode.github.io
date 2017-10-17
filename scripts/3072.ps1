Function Get-ChildItem {
<#

.ForwardHelpTargetName Get-ChildItem
.ForwardHelpCategory Cmdlet

#>

[CmdletBinding(DefaultParameterSetName='Items', SupportsTransactions=$true)]
param(
    [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    ${Path},

    [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')]
    [System.String[]]
    ${LiteralPath},

    [Parameter(Position=1)]
    [System.String]
    ${Filter},

    [System.String[]]
    ${Include},

    [System.String[]]
    ${Exclude},
    
    [System.String]
    ${Pattern},

    [Switch]
    ${Recurse},

    [Switch]
    ${BinarySizeInHumanReadableFormat},

    [Switch]
    ${Force},

    [Switch]
    ${Name})

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
        $cmd = ""
        if($BinarySizeInHumanReadableFormat) {
          $PSBoundParameters.Remove('BinarySizeInHumanReadableFormat') | Out-Null
          $cmd = @"
            | ForEach-Object {
                 `$_length=Switch(`$_.length) {
                  { `$_ -lt 1kb } 
                           {  '{0}B' -f (`$_) ;break }
                  { `$_ -lt 1MB }
                           {  '{0}KB' -f ([math]::round(`$(`$_/ 1kb)), 2) ;break }
                  { `$_ -lt 1gb }
                            { '{0}MB' -f ([math]::round(`$(`$_/ 1mb), 2)) ;break }
                  defaut { 
                            {  '{0}GB' -f ([math]::round(`$(`$_/ 1gb), 2)) ;break }
                   }
                }
                if(`$_.PSISContainer) { `$_length=`$null }
                 `$_ | Add-Member noteproperty size `$_.length -Pass |  
                    Add-Member noteproperty length `$_length -PassThru -Force              
            }         
"@
        }
        if($PSBoundParameters['Pattern']) {
          if($Filter -or $Include) {
           throw "les paramètres Pattern et Filter/Include sont mutuellemnt exculsive"
          } else {
          $PSBoundParameters.Remove('Pattern') | Out-Null
          $scriptCmd = {& $wrappedCmd @PSBoundParameters | Where { $_.Name -imatch "$Pattern"  } }
          }
        } else {
          $scriptCmd = {& $wrappedCmd @PSBoundParameters } 
        }
        $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
                $scriptCmd.ToString() + $cmd
            )
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

}
