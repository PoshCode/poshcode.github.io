#ThePowerShellTalk
#reconfigure-ha.ps1
#take a VMhost object from the pipeline and apply the 'Reconfigure HA host' task

Process {
    if ( $_ -isnot [VMware.VimAutomation.Client20.VMHostImpl] ) {
        Write-Error "VMHost expected, skipping object in pipeline."
        continue
    }
	$vmhostView = $_ | Get-View
    $vmhostView.ReconfigureHostForDAS_Task()
}
