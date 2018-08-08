function Invoke-CommandEx
{
	param
	(
		[String] $MutexName = $(throw "Name is required."),
		[ScriptBlock] $Scriptblock = $(throw "Scriptblock is required."),
		[Object[]] $ArgumentList
	)
	$MutexWasCreated = $false;
	$Mutex = $null;
	Write-Host "Waiting to acquire lock [$MutexName]..." -f Cyan
	[System.Reflection.Assembly]::LoadWithPartialName("System.Threading");
	try {
		$Mutex = [System.Threading.Mutex]::OpenExisting($MutexName);
	}catch{
		$Mutex = New-Object System.Threading.Mutex($true,$MutexName,[ref]$MutexWasCreated);
	}
	try {
		if(!$MutexWasCreated){
			$Mutex.WaitOne() | Out-Null;
		}
	}catch{}
	Write-Host "Lock [$MutexName] acquired. Executing..." -f Cyan
#region Execute Powershell V1 compatible
	foreach($arg in $ArgumentList){
		$params += "`"$arg`" ";
	}
	$cmd = @"
	function f{
		$Scriptblock
	}
	f $params
"@;
	Invoke-Expression $cmd
#endregion
	
	# This is powershell v2
	# Invoke-Command -ScriptBlock $Scriptblock -ArgumentList $ArgumentList  
	# We're done, Release lock, even if we exit before releasing the mutex will be abandoned
	Write-Host "Releasing lock [$MutexName]..." -f Cyan
	try {
		$Mutex.ReleaseMutex() | Out-Null;
	}catch{}
}
