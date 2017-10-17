if ((Test-Path  REGISTRY::HKEY_CLASSES_ROOT\OWC11.ChartSpace.11) -eq $False)
{
       Write-Host "This script requires Office Web Components to run correctly, please install these from the following website: http://www.microsoft.com/downloads/details.aspx?FamilyId=7287252C-402E-4F72-97A5-E0FD290D4B76&displaylang=en"
       exit
}
connect-VIServer yourserver

$Caption = "Datastore Usage %"

$categories = @()
$values = @()
$chart = new-object -com OWC11.ChartSpace.11
$chart.Clear()
$c = $chart.charts.Add(0)
$c.Type = 4
$c.HasTitle = "True"
$series = ([array] $chart.charts)[0].SeriesCollection.Add(0)

Get-datastore |Sort-Object FreeSpaceMB -Descending | foreach-object {

	$capacitymb = $_.CapacityMB
	$FreeSpaceMB = $_.FreeSpaceMB
	$UsedSpace = $capacitymb - $freespacemb

	$perc = $UsedSpace / $capacitymb * 100

	$categories += $_.Name
	$values += $perc * 1
}

$series.Caption = $Caption
$series.SetData(1, -1, $categories)
$series.SetData(2, -1, $values)
$filename = (resolve-path .).Path + "\Chart.jpg"
$chart.ExportPicture($filename, "jpg", 800, 500)
invoke-item $filename
