Param ( $DestinationHost )
Add-Type -Path "C:\Program Files\LeXtudio Software\sharpsnmplib.dll"
Add-Type -Path "C:\Program Files\LeXtudio Software\SharpSnmpLib.Controls.dll"
$manager = [system.Net.Dns]::Resolve( $DestinationHost ).AddressList[0]
$TrapDest = New-Object Net.IPEndPoint( $manager, 162 )

[Lextm.SharpSnmpLib.Messaging.Messenger]::SendTrapV1( $TrapDest,
	[IPAddress]::Loopback,
	[Lextm.SharpSnmpLib.OctetString]"public",
	[Lextm.SharpSnmpLib.ObjectIdentifier]"1.3.6",
	[Lextm.SharpSnmpLib.GenericCode]::ColdStart,
	0,
	0,
	( New-GenericObject.ps1 system.collections.generic.list lextm.sharpsnmplib.variable )
)
