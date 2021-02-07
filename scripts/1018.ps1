#.Synopsis
#  Draw pie charts of server memory usage by process
#.Description
#  Uses PowerBoots to draw a pipe-chart of each computer's memory use. While you wait for that information
#  to be gathered, it shows you the latest xkcd comic.   ##DEPEND-ON -Function Get-Comic https://PoshCode.org/1003
#  Uses the Transitionals library for nice transitions   ##DEPEND-ON -Assembly Transitionals http://www.codeplex.com/transitionals
#  Uses the Visifire libraries for the charts, of course ##DEPEND-ON -Assembly Transitionals http://visifire.com
#  Whoops, it's also dependent on Set-AttachedProperty   ##DEPEND-ON -Function Set-AttachedProperty https://PoshCode.org/1017
#  which for some reason isn't in PowerBoots yet!
#
#.Parameter hosts
#  The hostnames of the computers you want memory charts for
#.Example
#  Get-MemoryChart localhost
#
#  Returns a pie-chart of the memory on your local PC
#.Example
#  Get-MemoryChart Server01,Server02
#
#  Returns a pie-chart of the memory on Server01, and Server02
#  Note that this requires WMI and authorization...
#
Param([string[]]$hosts = "localhost")

Import-Module PowerBoots

if(!(Get-Command Chart -EA SilentlyContinue)) {
   Add-BootsContentProperty 'DataPoints', 'Series'
   Add-BootsFunction -Assembly "~\Documents\WindowsPowershell\Libraries\WPFVisifire.Charts.dll" 2>$Null
   Add-BootsFunction -Assembly "~\Documents\WindowsPowershell\Libraries\Transitionals.dll"
}

## And this is how you use a script which might not be there...
$comical = Get-Command Get-Comic -EA SilentlyContinue
if($comical) {
   $script:comic = Get-Comic xkcd
   $image = [system.drawing.image]::fromfile( $comic.FullName )
   $script:width = $image.Width
   $image.Dispose()
}

#$window = Boots { Image -Source $xkcd -MinHeight 100 } -Popup -Async

$limitsize = 10mb
$labellimitsize = 15mb
$window = Boots {
   DockPanel {
      # ListBox -DisplayMember Name -Ov global:list  `  # -width 0
      #        -On_SelectionChanged { $global:container[0].Content = $global:list[0].SelectedItem }
      # TransitionElement -Transition $(RotateTransition -Angle 45) `
      Frame `
                        -Name TransitionBox -Ov global:container   `
                        -MinWidth 400 -MinHeight 400 -MaxHeight 600 `
                        -Content {
                           StackPanel {
                              Label -FontSize 42 "Loading ..."
                              if($comical) {
                                 Image -Source $comic.FullName -MaxWidth $width
                              }
                           } |
         Set-AttachedProperty ([System.Windows.Navigation.JournalEntry]::NameProperty) "XKCD Comic"
      }
   } -LastChildFill $true
} -MinHeight 400 -Async -Popup -Passthru

sleep 2;

$jobs = @()
ForEach($pc in $hosts) {
   $jobs += gwmi Win32_Process -ComputerName $pc -AsJob;
}

while($jobs) {
   $job = Wait-Job -Any $jobs

   Invoke-BootsWindow $window {
      # if($list -is [System.Collections.ArrayList]) {
      #    $list = $list[0];
      #    $list.Padding = "2,2,5,2"
      # }

      $name = $($job.Location -Replace "[^a-zA-Z_0-9]" -replace "(^[0-9])",'_$1')
      # $null = $list.Items.Add(
      $global:container[0].Content = `
         $(
            Chart {
               DataSeries -LabelText $job.Location {
                  ForEach($proc in (Receive-Job $job | Sort WorkingSetSize)) {
                     if($proc.WorkingSetSize -gt $limitsize) {
                        DataPoint -YValue $proc.WorkingSetSize -LabelText $proc.Name `
                                  -LabelEnabled $($proc.WorkingSetSize -gt $labellimitsize) `
                                  -ToolTipText "$($proc.Name): #YValue (#Percentage%)"
                     }
                  }
               } -RenderAs Pie -ShowInLegend $false
            } -Watermark $false -AnimationEnabled $true -Name $name |
            Set-AttachedProperty ([System.Windows.Navigation.JournalEntry]::NameProperty) $name
         )
      # $list.SelectedIndex = $list.Items.Count - 1
   }

   $jobs = $jobs -ne $job
   Remove-Job $job.Id
   Sleep 5
}
