function repr {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $InputObject)

    process {
        if($null -eq $InputObject) {
            $PSCmdlet.WriteObject('$null')
        }
        elseif($InputObject -is [bool]) {
            $PSCmdlet.WriteObject('$' +
                $InputObject.ToString().ToLowerInvariant())
        }
        elseif($InputObject -is [scriptblock]) {
            $PSCmdlet.WriteObject("{$InputObject}")
        }
        elseif($InputObject -is [string]) {
            $PSCmdlet.WriteObject("'$InputObject'")
        }
        else {
            $PSCmdlet.WriteObject($InputObject.ToString())
        }
    }
}
