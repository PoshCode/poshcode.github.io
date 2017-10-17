# In order to enumerate all the WMI namespaces, you must first connect to the "root" namespace,
# query for all the "__NAMESPACE" instances, and for each instance recursively repeat this process.
# You can use the computerName parameter of Get-WmiNamespace to list the WMI namespaces on the remote computer.

function Get-WmiNamespace {
	param (
	[string]$rootns = "root",
	[string]$computerName = ".",
	$credential
	)

	if ($credential -is [String] ) {
		$credential = Get-Credential $credential
	}

	if ($credential -eq $null) {
		gwmi -class __namespace -namespace $rootns -computerName $computerName |
		where {$_.name} | foreach {
			$ns = "{0}\{1}" -f $rootns,$_.name
			$ns
			Get-WmiNamespace -rootns $ns -computer $computerName
		}
	}
	else {
		gwmi -class __namespace -namespace $rootns -computerName $computerName -credential $credential |
		where {$_.name} | foreach {
			$ns = "{0}\{1}" -f $rootns,$_.name
			$ns
			Get-WmiNamespace -rootns $ns -computer $computerName -credential $credential
		}
	}
}
