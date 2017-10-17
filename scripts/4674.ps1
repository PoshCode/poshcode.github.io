#requires -version 2.0
function Add-HostTime {
  $code = {
    while($true) {
      $run = (date) - (ps -id $pid).StartTime
      $new = '{0:d2}:{1:d2}:{2:d2}' -f $run.Hours, $run.Minutes, $run.Seconds
      [Console]::Title = $new
      Start-Sleep -sec 1
    }
  }
  
  $ps = [PowerShell]::Create()
  [void]$ps.AddScript($code)
  [void]$ps.BeginInvoke()
}
