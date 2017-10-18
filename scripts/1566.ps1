#################################################
#Scriptname:     checklock.ps1
#Author:         Michael Rüefli (www.miru.ch)
#Date:           21.11.2009
#Description:    The code uses a file locking mechanism to ensure that the
#                script beeing started is running exclusively. Mostly used where
#                a powershell script is started parallel within a few seconds
#
#Usage:          Paste your code in the MAIN section and set the $lockfile paramater to match your needs

############################################

$lockfile = “d:\lock.lck”
$lockstatus = 0
While ($lockstatus -ne 1)
{
	If (Test-Path $lockfile)
	{
		echo “Lock file found!”
		$pidlist = Get-content $lockfile
		If (!$pidlist)
		{
			$PID | Out-File $lockfile
			$lockstatus = 1
		}
		$currentproclist = Get-Process | ? { $_.id -match $pidlist }
		If ($currentproclist)
		{
			echo “lockfile in use by other process!”
			$rndwait = New-Object system.Random
			$rndwait=	$rndwait.next(500,1000)
			echo “Sleeping for $rndwait Milliseconds”
			Start-Sleep -Milliseconds $rndwait
		}
		Else
		{
			Remove-Item $lockfile -Force
			$PID | Out-File $lockfile
			$lockstatus = 1
		}
	}
	Else
	{
		$PID | Out-File $lockfile
		$lockstatus = 1
	}
}

#———————————————————————————————–
## Main Script Part
## Here you can paste your code, in fact what the script has to do
echo “Hi, it seems that no other script is doing the same as me now.. so I can do my job exclusively”

## End of Main Part
#———————————————————————————————–
#remove the lockfile
Remove-Item $lockfile -Force
