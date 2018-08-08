$DeploymentDir = '\\Server\Deployment\DotNET4.6_WMF4'

function message
{
	param 
	(
		[parameter(Mandatory=$true)]
		[string]$ErrorMessage
	)
	
	#Logfile
	$logFile = '\\Server\Logs\dotnet_deploy.log'
	
	#Build message
	$msg = "$env:ComputerName - "
	$msg += Get-Date -Format "yyyy-MM-dd h:mm tt - "
	$msg += $ErrorMessage
	
	#Log
	Add-Content $logFile "$StartTime - $msg "
	
	#Return value
	return $msg
}

#Check if .NET 4.5 is installed
$reg = Get-Item 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SKUs\.NETFramework,Version=v4.5' -ErrorAction SilentlyContinue
if (-not $reg)
{
	#Install .NET 4.5
	
	message "Installing .NET 4.5."
	try
	{
		Start-Process -Wait -FilePath "$DeploymentDir\NDP451-KB2858728-x86-x64-AllOS-ENU.exe" -ArgumentList '/CEIPconsent /norestart /q'
	}
	catch [System.Exception]
	{
		message "Failed to run .NET installer: $_"
	}
}
else
{
	message ".NET 4.5 already installed."
}

#Check if PowerShell 4.0 is installed
if($PSVersionTable.PSVersion.Major -ne '4')
{
	#32 or 64 bit?
	$OS = (GWMI Win32_Processor).AddressWidth

	#Install WMF 4
	if($OS -eq "32")
	{
		message "Installing WMF4 32-bit."
		try
		{
			Start-Process -Wait -FilePath 'wusa.exe' -ArgumentList "$DeploymentDir\Windows6.1-KB2819745-x86-MultiPkg.msu /quiet /norestart"
		}
		catch [System.Exception]
		{
			message "Failed to run .NET installer: $_"
		}
	}
	elseif($OS -eq "64")
	{
		message "Installing WMF4 64-bit."
		try
		{
			Start-Process -Wait -FilePath 'wusa.exe' -ArgumentList "$DeploymentDir\Windows6.1-KB2819745-x64-MultiPkg.msu /quiet /norestart"
		}
		catch [System.Exception]
		{
			message "Failed to run .NET installer: $_"
		}
	}
}
else
{
	message "WMF4 already installed."
}
