# Import-IISLog 
param ($Path)
get-content $Path |
  foreach {
    $_ -replace '#Fields: ', ''} |
      where { $_ -notmatch '^#'} |
        ConvertFrom-Csv -Delimiter ' ' |
          ForEach {
            $localTime = $(
              try { (Get-Date ('{0} {1}' -f $_.date, $_.time)).ToLocalTime() }
              catch {}
            )
            $_ | Add-Member -MemberType NoteProperty -Name 'LocalTime' -Value $localTime
	    $_
          }

