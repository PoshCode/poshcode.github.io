$Start = (get-date).AddDays(-1)
$End = Get-Date
$EventLog = Get-WinEvent -ComputerName atdb02 -FilterHashtable @{
	Logname = 'Security';
	Id = 4624;
	StartTime = $Start;
	EndTime = $End
} -ErrorAction Stop


ForEach ($Event in $EventLog)
{
	
	$xml = [xml]$Event.ToXml()
	
	For ($i = 0; $i -lt $xml.Event.EventData.Data.Count; $i++)
	{
		$Event |
		Add-Member -Force -NotePropertyName $xml.Event.EventData.Data[$i].name -NotePropertyValue $xml.Event.EventData.Data[$i].'#text'
	}
}

