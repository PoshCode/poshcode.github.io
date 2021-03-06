## Get-Weather 
## Parse and display the current weather and forecast from yahoo RSS
## Note that you _could_ modify this a bit to return "current condition" and "forecast" objects
##   but for now, it just prints them out in a relatively nice format
###################################################################################################
## Version History:
## 1.1 - Added TempColor function
## 1.0 - My initial cleanup of a script from 
##       http://fortheloveofcode.wordpress.com/2008/04/28/powershell-webservice-client/
#########
## ToDo: Color code the "text": Showers/Rain/Snow/...
## ToDo: Pull out extreme weather *Warnings*
## ToDo: Parse wind and show the wind-chill when temp is cold
###################################################################################################
# function get-weather {
param($zip=14586,[switch]$celcius)
$url = "http://weather.yahooapis.com/forecastrss?p={0}{1}" -f $zip, $(if($celcius){"&u=c"})

$channel = ([xml](New-Object Net.WebClient).DownloadString($url)).rss.channel

function TempColor ($temp) {
   if($celcius) { 
      if( $temp -lt 0 ) { "blue" } elseif( $temp -lt 10 ) { "cyan" } elseif( $temp -lt 25 ) { "green" } elseif( $temp -lt 30 ) { "yellow" } else { "red" } 
   } else { 
      if( $temp -lt 5 ) { "blue" } elseif( $temp -lt 50 ) { "cyan" } elseif( $temp -lt 77 ) { "green" } elseif( $temp -lt 85 ) { "yellow" } else { "red" }
   }
}

if($channel) {
   $current = $channel.item.condition
   Write-Host
   Write-Host ("Location:    {0}" -f $channel.location.city)
   Write-Host ("Last Update: {0}" -f $channel.lastBuildDate)
   Write-Host ("Weather:     {0}" -f $current.text)-NoNewline
   Write-Host (" {0}°{1}" -f $current.temp, $(if($celcius){"C"}else{"F"})) -ForegroundColor $(TempColor $current.temp)
   Write-Host
   Write-Host "Forecasts"
   Write-Host "---------"
   foreach ($f in $channel.item.forecast) {
      Write-Host ("`t{0}, {1}: {2}" -f $f.day, $f.date, $f.text) -NoNewline
      Write-Host (" {0}-{1}°{2}" -f $f.low, $f.high, $(if($celcius){"C"}else{"F"})) -ForegroundColor $(TempColor $f.High)
   }
   Write-Host
}
#}
