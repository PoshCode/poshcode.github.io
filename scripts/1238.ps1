#requires -version 2
$NetSnmp = Join-Path $env:programfiles "Net-SNMP\bin"
	if ( -not ( Test-Path "$NetSnmp\snmpwalk.exe" ) ) {
		Throw "Net-SNMP binaries not found in $NetSnmp. Please install to this folder `
			or edit the NetSnmp variable as appropriate."
	}

# Modeled after SNMPWALK http://www.net-snmp.org/docs/man/snmpwalk.html
function Get-SnmpValue {
	param (
		[Parameter( Position = 0, Mandatory = $true )] $Agent,
		[Parameter( Position = 1, Mandatory = $true )] $OID,
		$Port = 161,
		$Community = "public",
		$Version = "2c"
	)
	&"$NetSnmp\snmpwalk.exe" "-v$Version" "-c$Community" "${Agent}:$Port" "$OID"
}
