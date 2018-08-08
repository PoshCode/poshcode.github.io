$endDate  = New-Object datetime(2013,1, 1) 
for ($date = [DateTime]::Today; $date -le $endDate; $date = $date.AddDays(1);)
{
  if ($date.DayOfWeek -ne [DayOfWeek]::Saturday -and $date.DayOfWeek -ne [DayOfWeek]::Saturday)
   {
    New-Item -type directory $date.ToShortDateString()
  }
}
