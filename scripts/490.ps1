connect-VIServer yourserver

# Written by Alan Renouf - Check http://teckinfo.blogspot.com for more examples
# This can easily be changed to pass parameters or be used as a function
# Set the following 3 variables for your needs
# Example stats are:
# % CPU Usage - cpu.usage.average
# Mhz CPU Usage - cpu.usageMHZ.average
# % Memory Usage - mem.usage.average
# Kbps Network Usage - net.usage.average
# Kbps Disk Usage - disk.usage.average

$Caption = "CPU Usage"
$Stat = "cpu.usage.average"
$NumToReturn = 20

$categories = @()
$values = @()
$chart = new-object -com OWC11.ChartSpace.11
$chart.Clear()
$c = $chart.charts.Add(0)
$c.Type = 4
$c.HasTitle = "True"
$series = ([array] $chart.charts)[0].SeriesCollection.Add(0)

Get-Stat -Entity (Get-vm) -Stat $stat -MaxSamples 1 -Realtime |Sort-Object Value -Descending | Select-Object Entity, Value -First $NumToReturn | foreach-object {

	$categories += $_.Entity.Name
	$values += $_.Value * 1
}

$series.Caption = $Caption
$series.SetData(1, -1, $categories)
$series.SetData(2, -1, $values)
$filename = (resolve-path .).Path + "\Chart.jpg"
$chart.ExportPicture($filename, "jpg", 800, 500)
invoke-item $filename
