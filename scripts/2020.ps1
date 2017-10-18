$getVmScript = { 
	Connect-VIServer yourVCenterServer
	Get-VM
}
$ getVmScript | Get-ErrorReport -ProblemScriptTimeoutSeconds 60 -ProblemDescription "Get-VM hangs when trying to retrieve all the VMs form the server. The server’s inventory can be successfully browsed via the vClient." -Destination 'D:\bug report' 

