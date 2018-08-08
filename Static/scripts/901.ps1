#requires -version 2 
#requires -pssnapin VMware.VimAutomation.Core 
Function Disconnect-VMHost {
    <#
    .Summary
        Used to Disconnect a Connected host from vCenter.
    .Parameter VMHost
        VMHost to Disconnect to virtual center
    .Example
        Get-VMHost | Where-Object {$_.state -eq "Connected"} | Disconnect-VMHost
        
        Will Attempt to Disconnect any host that are currently Connected.
    .Example
        Disconnect-VMHost -Name ESX1.get-admin.local
        
        Will Disconnect ESX1 From vCenter
    #>
    [CmdletBinding(
        SupportsShouldProcess=$True,
	    SupportsTransactions=$False,
	    ConfirmImpact="low",
	    DefaultParameterSetName="ByString"
	)]
    Param(
        [Parameter(
            Mandatory=$True,
            Valuefrompipeline=$true,
            ParameterSetName="ByObj"
        )]
        [VMware.VimAutomation.Client20.VMHostImpl[]]
        $VMHost,
        
        [Parameter(
            Mandatory=$True,
            Position=0,
            ParameterSetName="ByString"
        )]
        [string[]]
        $Name
    )
    Begin {
        IF ($Name) {
            $VMHost = $Name|%{ Get-VMHost -Name $_ }
        }
    }
    process {
        Foreach ($VMHostImpl in ($VMHost|Get-View)) {
            if ($pscmdlet.ShouldProcess($VMHostImpl.name)) {
                $VMHostImpl.DisconnectHost_Task()
            }
        }
    }
}
