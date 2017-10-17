$rk = gi 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Prefetcher'
'{0:D2}:{1:D2}:{2:D2} up {3} days' -f ($ts = 
  [DateTime]$rk.GetValue('ExitTime').Replace('-', ' ') -
    [DateTime]$rk.GetValue('StartTime').Replace('-', ' ')
).Hours, $ts.Minutes, $ts.Seconds, $ts.Days
$rk.Close()
