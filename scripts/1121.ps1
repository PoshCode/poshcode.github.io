function sync-time(
[string] $server = "clock.psu.edu",
[int] $port = 37)
{
  $servertime = get-time -server $server -port $port -set
  #leave off -set to just check the remote time
  write-host "Server time:" $servertime 
  write-host "Local time :" $(date)
}


