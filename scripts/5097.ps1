#just a magic :)
[DateTime]::Parse((date) - (ps -id $pid).StartTime).ToLongTimeString()
