#require -version 2.0
#require -shellid PoshConsole
###################################################################################################
## Get-Weather 
## Parse and display the current weather and forecast from yahoo RSS
## Note that you _could_ modify this a bit to return "current condition" and "forecast" objects
##   but for now, it just prints them out in a relatively nice format
###################################################################################################
## Version History:
## 2.2 - removed reference to "Out-WPF" which is just a function now
## 2.1 - Updated for New-BootsWindow 2.0, can show -Popup graphics even in PowerShell.exe (with New-BootsWindow)
## 2.0 - Updated for New-BootsWindow and PoshConsole, now shows inline graphics in PoshConsole, 
## 1.1 - Added TempColor function
## 1.0 - My initial cleanup of a script from 
##       http`://fortheloveofcode.wordpress.com/2008/04/28/powershell-webservice-client/
#########
## ToDo: Color code the "text": Showers/Rain/Snow/...
## ToDo: Pull out extreme weather *Warnings*
## ToDo: Parse wind and show the wind-chill when temp is cold
###################################################################################################
# function get-weather {
param($zip=14586,[switch]$celcius,[switch]$Popup)
$url = "http`://weather.yahooapis.com/forecastrss?p={0}{1}" -f $zip, $(if($celcius){"&u=c"})

$channel = ([xml](New-Object Net.WebClient).DownloadString($url)).rss.channel

function TempColor ($temp) {
   if($celcius) { 
      if( $temp -lt 0 ) { "blue" } elseif( $temp -le 10 ) { "cyan" } elseif( $temp -le 21 ) { "blue" } elseif( $temp -lt 27 ) { "green" } else { "red" } 
   } else { 
      if( $temp -lt 5 ) { "blue" } elseif( $temp -le 50 ) { "cyan" } elseif( $temp -le 70 ) { "blue" } elseif( $temp -lt 80 ) { "green" } else { "red" }
   }
}

if($channel) {
   if( ($Host.PrivateData.GetType().Name  -eq "PoshOptions") -OR ( $Popup -AND (Get-Command New-BootsWindow -Type Cmdlet -EA SilentlyContinue))) { 
      # alternate images: http`://l.yimg.com/us.yimg.com/i/us/we/52/
      $template = @"
  <StackPanel xmlns="http`://schemas.microsoft.com/winfx/2006/xaml/presentation" >
  <TextBlock FontFamily="Constantia" FontSize="12pt">{0}, {1} {2}</TextBlock>
  <StackPanel Orientation="Horizontal">
  <StackPanel VerticalAlignment="Top" Margin="6,2,6,2" ToolTip="{3}">
  <Image Source="http`://image.weather.com/web/common/wxicons/52/{4}.png" Stretch="Uniform"
         Width="{{Binding Source.PixelWidth,RelativeSource={{RelativeSource Self}}}}"
         Height="{{Binding Source.PixelHeight,RelativeSource={{RelativeSource Self}}}}" />
  <TextBlock TextAlignment="Center"><Run FontWeight="700" Text="Now: " /><Run Foreground="{5}"> {6}{7}</Run></TextBlock>
  </StackPanel>
  <StackPanel VerticalAlignment="Top" Margin="6,2,6,2" ToolTip="{8}">
  <Image Source="http`://image.weather.com/web/common/wxicons/52/{9}.png" Stretch="Uniform"
         Width="{{Binding Source.PixelWidth,RelativeSource={{RelativeSource Self}}}}"
         Height="{{Binding Source.PixelHeight,RelativeSource={{RelativeSource Self}}}}" />
  <TextBlock TextAlignment="Center">
    <Run FontWeight="700">{10}</Run><LineBreak/>
    <Run Foreground="{11}">{12}{7}</Run> - <Run Foreground="{13}">{14}{7}</Run></TextBlock>
  </StackPanel>
  <StackPanel VerticalAlignment="Top" Margin="6,2,6,2" ToolTip="{15}">
  <Image Source="http`://image.weather.com/web/common/wxicons/52/{16}.png" Stretch="Uniform"
         Width="{{Binding Source.PixelWidth,RelativeSource={{RelativeSource Self}}}}"
         Height="{{Binding Source.PixelHeight,RelativeSource={{RelativeSource Self}}}}" />
  <TextBlock TextAlignment="Center">
  <Run FontWeight="700">{17}</Run><LineBreak/>
  <Run Foreground="{18}">{19}{7}</Run> - <Run Foreground="{20}">{21}{7}</Run></TextBlock>
  </StackPanel>
  </StackPanel>
  </StackPanel>
"@ 

      $template = ($template -f $channel.location.city,  $channel.location.region, $channel.lastBuildDate, 
      $channel.item.condition.text, $channel.item.condition.code, (TempColor $channel.item.condition.temp), $channel.item.condition.temp,
      $channel.units.temperature, $channel.item.forecast[0].text, $channel.item.forecast[0].code, 
      $channel.item.forecast[0].day, (TempColor $channel.item.forecast[0].low), $channel.item.forecast[0].low, (TempColor $channel.item.forecast[0].high), $channel.item.forecast[0].high, 
      $channel.item.forecast[1].text, $channel.item.forecast[1].code, $channel.item.forecast[1].day,
      (TempColor $channel.item.forecast[1].low), $channel.item.forecast[1].low, (TempColor $channel.item.forecast[1].high), $channel.item.forecast[1].high)

      $template | out-clipboard
      ## Work around defect in New-BootsWindow that hides -Popup when -Popup is implied. Silly of me.
      if(!$Popup -and $Host.PrivateData.GetType().Name  -eq "PoshOptions") {
         New-BootsWindow -SourceTemplate $template -Inline {}
      } else {
         New-BootsWindow -SourceTemplate $template {} -Async
      }

   } else { # "ConsoleColorProxy"
      
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
}
#}
