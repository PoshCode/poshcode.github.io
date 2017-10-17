Get-WmiObject Win32_Service -ComputerName . |`
	where 	{($_.startmode -like "*auto*") -and `
		($_.state -notlike "*running*")}|`
	select DisplayName,Name,StartMode,State|ft -AutoSize
