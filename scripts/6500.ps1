Update-TypeData -Force -TypeName DateTime -MemberType ScriptProperty -MemberName Week -Value {
   [System.Globalization.CultureInfo]$Culture = [System.Globalization.CultureInfo]::CurrentCulture
   return $Culture.Calendar.GetWeekOfYear($this, $Culture.DateTimeFormat.CalendarWeekRule, $Culture.DateTimeFormat.FirstDayOfWeek)
}

