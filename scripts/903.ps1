# WS-MAN monitoring of ESX with PowerShell.
# This requires PowerShell v2 CTP3 and requires the new WS-MAN CTP
# from MS (currently 64 bit only)
# You will also need to allow basic auth.
# (run winrm set winrm/config/client/auth @{Basic="true"} from command prompt)
function Get-VMHostWSManInstance {
	param (
	[Parameter(Mandatory=$TRUE,HelpMessage="VMHosts to probe")]
	[VMware.VimAutomation.Client20.VMHostImpl[]]
	$VMHost,

	[Parameter(Mandatory=$TRUE,HelpMessage="Resource URI")]
	[string]
	$resourceUri,

	[switch]
	$ignoreCertFailures
	)

	if ($ignoreCertFailures) {
		$option = New-WSManSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
	} else {
		$option = New-WSManSessionOption
	}
	foreach ($H in $VMHost) {
		$hView = $H | Get-View -property Value
		$ticket = $hView.AcquireCimServicesTicket()
		$password = convertto-securestring $ticket.SessionId -asplaintext -force
		$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $ticket.SessionId, $password
		$uri = "https`://" + $h.Name + "/wsman"
		Get-WSManInstance -Authentication basic -ConnectionURI $uri -Credential $credential -Enumerate -Port 443 -UseSSL  -SessionOption $option -ResourceURI $resourceUri
	}
}

# Example
# First, connect to your VI Server.
# Connect-VIServer <your ESX or VC>

# Now we're ready to enumerate stuff. This will get processor
# information for all hosts.
# Get-VMHostWSManInstance -VMHost (get-vmhost) `
#   -resourceUri http`://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_Processor `
#   -ignoreCertFailures

# Other resource URIs of note
# http`://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_Chassis
# http`://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_Processor
# http`://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_Memory
# http`://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_SoftwareElement
# Some of these may not be supported on your hardware.
