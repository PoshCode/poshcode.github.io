#.Example
#   Get-WmiObject -computername Z002 Win32_LogicalDisk -filter "DriveType=3" | New-DiskSpace
#.Note
#   Requires ShowUI 1.1 and Visifire (You must use Add-UIModule on the Visifire dll and then import it)

function New-DiskSpace {
param([Parameter(ValueFromPipeline=$true)]$InputObject)
begin {
    $chart = Chart -MinHeight 100 -MinWidth 200 -Theme Theme2 -View3D `
          -BorderBrush Gray -CornerRadius 5 -BorderThickness 0.5 `
          -AnimationEnabled:$false -Series {
            DataSeries -RenderAs StackedBar -LegendText UsedSpace -LabelEnabled $true
            DataSeries -RenderAs StackedBar -LegendText FreeSpace -LabelEnabled $true #  -RadiusX 5 -RadiusY 5
        }
}
process {
    foreach ($disk in $InputObject) {
        [double]$free = [System.Math]::Round(($disk.FreeSpace/1GB),2)
        [int]$pFree = ([double]$disk.FreeSpace/[double]$disk.Size) * 100

        [double]$used = [System.Math]::Round((([double]$disk.Size - [double]$disk.FreeSpace)/1GB),2)
        [int]$pUsed = (([double]$disk.Size - [double]$disk.FreeSpace)/[double]$disk.Size) * 100

        $dp1 = DataPoint -AxisXLabel $disk.Name -YValue $used -LabelText "$pUsed%" -
        $chart.Series[0].DataPoints.Add($dp1)

        $dp2 = DataPoint -YValue $free -LabelText "$pFree%" 
        $chart.Series[1].DataPoints.Add($dp2)
    }
}
end {
    Grid -ControlName "DiskSpace Chart" { $chart } -show
}
}
