workflow UninstallSoftware
{
	Param(
		[Parameter(Mandatory=$True)]
		[String[]]$ComputersList,
		[Parameter(Mandatory=$True)]
		[String[]]$GUID
	)
	
	function Uninstall
	{
		param
		(  
			[Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
			[String]$ComputerName = $env:computername,
			[Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
			[String]$AppGUID
		)  
		
		try 
		{
			$returnval = ([WMICLASS]"\\$computerName\ROOT\CIMV2:win32_process").Create("msiexec `/x$AppGUID `/norestart `/qn")
		} 
		catch 
		{
			write-error "Failed to trigger the uninstallation. Review the error message"
			$_
			exit
		}
		
		switch ($($returnval.returnvalue))
		{
			0 { "Uninstallation command triggered successfully" }
			2 { "You don't have sufficient permissions to trigger the command on $Computer" }
			3 { "You don't have sufficient permissions to trigger the command on $Computer" }
			8 { "An unknown error has occurred" }
			9 { "Path Not Found" }
			9 { "Invalid Parameter"}
		}
	}
	
	$Computers = Get-Content $ComputersList
	
	Foreach -Parallel ($Computer in $Computers)
	{
		Uninstall -ComputerName $Computer -AppGUID $GUID
	}
}

UninstallSoftware -ComputersList 'X:\computers_test.txt' -GUID '{39A086B2-07D6-430B-AE5E-B8AC1CC843A7}'
