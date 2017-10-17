function Measure-Command {
    [CmdletBinding()]
    param(
        [ScriptBlock]$Command,
        [Int]$Iterations = 10,
        [Switch]$NoBuffer
    )
    
    if(!$NoBuffer) { $Null = & $Command }       

    $watch = [System.Diagnostics.Stopwatch]::new()
    $watch.Start()
    $Measurements = for($i=0; $i -lt $Iterations; $i++) {
            $1 = $watch.ElapsedTicks
            $Null = &$Command
            $2 = $watch.ElapsedTicks
            $2 - $1
    }
    $Measurements | 
        Measure-Object -Average -Minimum -Maximum | 
        &{
            process{
                [PSCustomObject]@{
                    PSTypeName = "ExecutionPerformance"
                    Average = [Timespan]::FromTicks($_.Average)
                    Maximum = [Timespan]::FromTicks($_.Maximum)
                    Minimum = [Timespan]::FromTicks($_.Minimum)
                    Iterations = $Iterations
                    Command = "$Command"
                }
            }
        }
}
