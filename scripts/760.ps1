$computers = gc "listofservers.txt"

Get-WmiObject Win32_NetworkAdapterConfiguration -computer $computers -filter "IPEnabled ='true'" | select __Server,IPAddress
