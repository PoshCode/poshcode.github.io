# map2_gps_prod.ps1
# Maps a network drive using PowerShell
# 
# 
# 
#

	$Drive = "O:"
	$UNC = "\\ampwcsqlsvr2\nam401k"
cls

# if the drive exists just remove it
	
	if (((New-Object -Com WScript.Network).EnumNetworkDrives() | Where-Object `
{$_ -eq $Drive})) 
	{ # true remove drive
	
	# Create the Com object with New-Object -com
	$net = $(New-Object -comobject WScript.Network)
	$net.RemoveNetworkDrive($Drive,1)
	
	
	} 
# if the drive does not exist just add it
if (!((New-Object -Com WScript.Network).EnumNetworkDrives() | Where-Object `
{$_ -eq $Drive}))
		{
		# Create the Com object with New-Object -com
		$net = $(New-Object -comobject WScript.Network)
		$net.mapnetworkdrive($Drive,$Unc) 
		}

# Launches windows Explorer and goes to the maped drive
explorer.exe $Drive



