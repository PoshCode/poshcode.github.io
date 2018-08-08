# Logpings.ps1
# Version: 1.0
# Author: Jacob Saaby Nielsen
# Author E-Mail: jsy@systematic.com
# Purpose: Repeatedly ping a host, document lost pings to a logfile
# Syntax: .\Logpings hostname interval (where interval is a value representing seconds)
# Requirements: /n Software's NetCmdlets http://www.nsoftware.com/powershell/

$PingedHost = $Args[0]
$PingTime = $Args[1]
$LogPath = 'c:\'
$KillSwitch = 1

while ($KillSwitch -ne 0)
{
	Send-Ping $PingedHost
	if ($PingedHost.Status -ne "OK")
		{
			'Lost connectivity at: ' + $(Get-Date -format "dd-MM-yyyy @ hh:mm:ss") | Out-File $($LogPath + $(Get-Date -format "dd-MM-yyyy") + '.log') -noClobber -append
			$Error.Clear()
			Start-Sleep $PingTime
		}
	else
		{
			Start-Sleep $PingTime
		}
}
