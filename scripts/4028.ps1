ps | % -b {$arr = @()} -p {
  $str = "" | select Name, PID, Time
  $str.Name = $_.ProcessName
  $str.PID  = $_.Id
  $str.Time = $(try {$_.StartTime} catch {return [DateTime]::MinValue})
  $arr += $str
} -end {$arr | sort Time | ft -a}
