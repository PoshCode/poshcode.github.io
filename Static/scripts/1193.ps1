# http://blogs.msdn.com/powershell/archive/2008/05/09/fun-with-script-cmdlets.aspx
########################################################################################
# function New-ScriptCmdlet() {
[CmdletBinding(DefaultParameterSetName="Type")]
PARAM(
   [Parameter(ParameterSetName="Type",ValueFromPipeline=$true,Position=1)]
   [Type]
   $type
,
   [Parameter(ParameterSetName="CommandInfo",ValueFromPipeline=$true,Position=1)]
   [Management.Automation.CmdletInfo]
   $commandInfo
,
   [Parameter(Position=0)]
   [string]
   $name
)

    Process
    {
        if (! $type) {
            if ($commandInfo.ImplementingType) { $type = $commandInfo.ImplementingType }
        }

        if ((! $type) -and (! $commandInfo)) {
@"
$(if ($name) { 'function ' + $name + '() {' })
[CmdletBinding()]
param   ()
begin   {}
process {}
end     {}
$(if ($name) {'}' })
"@
        } else {
            if (! ($type.IsSubclassOf([Management.Automation.Cmdlet]))) {
                throw "Must provide a cmdlet to create a proxy"
            }

            $commandMetaData = New-Object Management.Automation.CommandMetadata $type
            $proxyCommand =
@"
$(if ($name) { 'function ' + $name + '() {' })
$([Management.Automation.ProxyCommand]::Create($commandMetaData))
$(if ($name) {'}' })
"@

            $executionContext.InvokeCommand.NewScriptBlock($proxyCommand)
        }
    }
#}
