# Get-CalendarWeek by Holger Adam
# Simple function to retrieve the calendar week to a given or the current date.
# The function always assumes a calendar week rule of at least four days and the week starting with monday.

function Get-CalendarWeek {
	param(
		$Date
	)
	
	# check date input
	if ($Date -eq $null)
	{
		$Date = Get-Date
	}

	# create calendar object
	$Calendar = New-Object System.Globalization.GregorianCalendar
	
	# retrieve calendar week
	$Calendar.GetWeekOfYear($Date, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [System.DayOfWeek]::Monday)
}
