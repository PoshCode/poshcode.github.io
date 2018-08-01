#requires -version 2.0
Import-Module Accelerators  # http://poshcode.org/762
Import-Module PowerBoots    # http://boots.codeplex.com
                            # http://dynamicdatadisplay.codeplex.com
## You have to get the DynamicDataDisplay control, and put it's DLLs in the PowerBoots folder...
ls "$PowerBootsPath\DynamicDataDisplay*.dll" | Add-BootsFunction

## This sets up all the types, and requires the accelerators and the DynamicDataDisplay.dll 
Add-Accelerator TimedDouble "System.Collections.Generic.KeyValuePair[DateTime,Double]"
Add-Accelerator TimedDoubleRing "Microsoft.Research.DynamicDataDisplay.Common.RingArray[System.Collections.Generic.KeyValuePair[DateTime,Double]]"
Add-Accelerator EnumerableDataSource "Microsoft.Research.DynamicDataDisplay.DataSources.EnumerableDataSource``1"

function Add-Monitor {
#.Synopsis
#  Create a new monitor line
   Param(
      [String]$global:Label="HuddledMasses", 
      [ScriptBlock]$global:Script= { 
         New-Object TimedDouble (Get-Date), ([regex]"time=(\d+)ms").Match( (ping.exe "HuddledMasses.org" -n 1) ).Groups[1].Value 
      },      
      $global:XMapping = $([System.Func[TimedDouble, Double]]{ param([TimedDouble]$value); $value.Key.TimeOfDay.TotalSeconds }),
      $global:YMapping = $([System.Func[TimedDouble, Double]]{ param([TimedDouble]$value); $value.Value })
   )

   Invoke-BootsWindow $Global:Plotter {
      $dataSource = New-Object "EnumerableDataSource[System.Collections.Generic.KeyValuePair[DateTime,Double]]" (New-Object TimedDoubleRing $global:RingSize)
      $dataSource.SetXMapping( $global:XMapping )
      $dataSource.SetYMapping( $global:YMapping )
      $Global:Plotter.Children.Add( (
         LineGraph -Description $(New-Object Microsoft.Research.DynamicDataDisplay.PenDescription $global:Label) `
                   -DataSource $dataSource -Filters { InclinationFilter; FrequencyFilter } `
                   -LinePen (Pen -Brush (SolidColorBrush -Color $([Microsoft.Research.DynamicDataDisplay.ColorHelper]::CreateRandomHsbColor())) -Thickness 2.0) `
                   -Tag {$global:Script} -Name $($global:Label -replace "[^\p{L}]")
      ))
   }
}


function Remove-Monitor {
#.Synopsis
#   Remove a monitor line
   Param( [String]$global:Label="HuddledMasses" )

   Invoke-BootsWindow $Global:Plotter {
      $Global:Plotter.Children.Remove( $(
         $Global:Plotter.Children | 
            Where-Object { ($_ -is [Microsoft.Research.DynamicDataDisplay.LineGraph]) -and ($_.Name -eq $Label) } |
            Select -First 1 ) )
   }
}
function Global:Update-Ring {
#.Synopsis
#   Internal function for updating all the data lines
   foreach($graph in $Plotter.Children | ?{$_ -is [Microsoft.Research.DynamicDataDisplay.LineGraph]} ) {
      $graph.DataSource.Data.Add( (&$graph.Tag) )
   }
}

Function New-RingMonitor {
#.Synopsis
#  Creates a new Ring Monitor graph window, and sets the update interval for it
Param(
   [TimeSpan]$global:Interval = "00:00:02",
   [Int]$global:RingSize = 200
)

   New-BootsWindow {
      Param($global:w)
      $w.Tag = DispatcherTimer -Interval $global:Interval -On_Tick Update-Ring
      $w.Tag.Start()
      $w.Add_Closed( { $this.Tag.Stop() } )

      ChartPlotter | Tee -Var Global:Plotter
   } -Width 800 -Height 600 -Async -Title "Ring Monitor"
} #-WindowStyle None -AllowsTransparency -Background Transparent -On_MouseLeftButtonDown { $this.DragMove() } -ResizeMode CanResizeWithGrip


####################################################################################################
## Examples: Hopefully you get the idea you can graph anything you like....
####################################################################################################
# New-RingMonitor
#
# Add-Monitor Memory { 
#      New-Object TimedDouble (Get-Date), (gwmi Win32_PerfFormattedData_PerfOS_Memory AvailableBytes).AvailableBytes
# }
#
# Add-Monitor CPU { 
#     New-Object TimedDouble (Get-Date), (gwmi Win32_PerfFormattedData_PerfOS_Processor PercentIdleTime,Name |?{$_.Name -eq "_Total"}).PercentIdleTime
# }
# ## Yuck. those two numbers won't work together, because they're too far apart.
# ## Let's remove the first one and make it percentage based
# Remove-Monitor Memory
#
# Add-Monitor Memory { 
#   New-Object TimedDouble (Get-Date), ((gwmi Win32_PerfFormattedData_PerfOS_Memory AvailableBytes).AvailableBytes / (gwmi Win32_ComputerSystem TotalPhysicalMemory).TotalPhysicalMemory * 100)
#  }

####################################################################################################
# New-RingMonitor
#
# Add-Monitor Twitter { 
#    New-Object TimedDouble (Get-Date), ([regex]"time=(\d+)ms").Match( (ping.exe "Twitter.com" -n 1) ).Groups[1].Value 
# }

