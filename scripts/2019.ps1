$moveVmScript = { 
	Connect-VIServer yourVCenterServer
	Move-VM WinXP -Location yourDestinationHost
}
$ moveVmScript | Get-ErrorReport -ProblemScriptTimeoutSeconds 120 -ProblemDescription "An error is returned by Move-VM. The operation should be successful. The same can be done via the vClient." -Destination 'D:\bug report' –DontIncludeServerLogs
