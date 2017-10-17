function Test-Confirm {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    param([Switch]$Force)

    $RejectAll = $false;
    $ConfirmAll = $false;
    Write-Verbose "ConfirmPreference is $ConfirmPreference"

    foreach($file in ls) {
        if($PSCmdlet.ShouldProcess( "Removed the file '$($file.Name)'",
                                    "Remove the file '$($file.Name)'?",
                                    "Removing Files" )) {
            if($Force -Or $PSCmdlet.ShouldContinue("Are you REALLY sure you want to remove '$($file.Name)'?", "Removing '$($file.Name)'", [ref]$ConfirmAll, [ref]$RejectAll)) {
                "Removing $File"
            }
        }
    }
}
