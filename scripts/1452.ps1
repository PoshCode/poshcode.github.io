$Shell = New-Object -com shell.application
$NetCons = $Shell.Namespace(0x31)
$NetCons.Items() | 
	where {$_.Name -like 'Local Area Connection*'} | 
		foreach{$AdapName=$_.Name; get-WmiObject -class Win32_NetworkAdapter | 
			where-Object {$_.NetConnectionID -eq $AdapName} | 
				foreach {$MAC=$_.MacAddress}
					$_.Name=$MAC.replace(':','.')
				}
