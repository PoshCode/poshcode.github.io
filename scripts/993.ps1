#Usage: Get-SqlDatabase 'Z002\Sql2k8' | where {$_.name -like "pubs*"} | ./WPFDbSpace.ps1
#Note: Requires .NET 3.5, Visifire Charts (tested on v2.1.0), Powerboots (tested on v0.1), and SQLPSX (tested on v1.5)

$libraryDir = Convert-Path (Resolve-Path "$ProfileDir\Libraries")
[Void][Reflection.Assembly]::LoadFrom( (Convert-Path (Resolve-Path "$libraryDir\WPFVisifire.Charts.dll")) )
. $libraryDir\LibrarySmo.ps1

if (!(Get-PSSnapin | ?{$_.name -eq 'PoshWpf'}))
{ Add-PsSnapin PoshWpf }

New-BootsWindow -Async {
    $chart = New-Object Visifire.Charts.Chart
    $chart.Height = 500 
    $chart.Width = 800 
    $chart.watermark = $false
    $chart.Theme = "Theme2"
    $chart.View3D = $true
    $chart.BorderBrush = [System.Windows.Media.Brush]"Gray"
    $chart.CornerRadius = [System.Windows.CornerRadius]5
    $chart.BorderThickness = [System.Windows.Thickness]0.5
    $chart.AnimationEnabled = $false

    $ds1 = New-Object Visifire.Charts.DataSeries
    $ds1.RenderAs = [Visifire.Charts.RenderAs]"StackedBar"
    $ds1.LegendText = "UsedSpace"
    $ds1.LabelEnabled = $true
    $ds1.LabelText = "#YValue"

    $ds2 = New-Object Visifire.Charts.DataSeries
    $ds2.RenderAs = [Visifire.Charts.RenderAs]"StackedBar"
    $ds2.LegendText = "FreeSpace"
    $ds2.LabelEnabled = $true
    $ds2.LabelText = "#YValue"
    $ds2.RadiusX = 5
    $ds2.RadiusY = 5
 
    foreach ($db in $input)
    {
        if ($db.GetType().Name -ne 'Database')
        { throw 'Input must be Database object' } 
        
        foreach ($file in Get-SqlDataFile $db)
        {
            $dp1 = new-object Visifire.Charts.DataPoint
            $dp1.AxisXLabel = ($db.Name + '.' + $file.Name)
            $dp1.YValue = ([int]($file.UsedSpace/1KB))
            $ds1.DataPoints.Add($dp1)

            $dp2 = new-object Visifire.Charts.DataPoint
            $dp2.YValue = ([int](($file.Size - $file.UsedSpace)/1KB))
            $ds2.DataPoints.Add($dp2)
        }

        $log = Get-SqlLogFile $db

        $dp3 = new-object Visifire.Charts.DataPoint
        $dp3.AxisXLabel = ($db.Name + '.' + $log.Name)
        $dp3.YValue = ([int]($log.UsedSpace/1KB))
        $ds1.DataPoints.Add($dp3)

        $dp4 = new-object Visifire.Charts.DataPoint
        $dp4.YValue = ([int](($log.Size - $log.UsedSpace)/1KB))
        $ds2.DataPoints.Add($dp4)


    }   
    $chart.Series.Add($ds1)
    $chart.Series.Add($ds2)

    $chart
} -Title "Database Space"
