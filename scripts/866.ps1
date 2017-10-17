function Get-FridaysThirteenth {
	param (
		[datetime]$end = "12/31/2010"
	)
	
	[DateTime]$begin = "02/13/2009"
	for ($i = $begin; $i -lt $end; $i = $i.AddMonths(1)) {
		if ($i.DayOfWeek -eq 'Friday') {
			"{0:d}" -f $i 
		} #if
	} #for
} #function
