function Get-StandardDeviation {
    [CmdletBinding()]
    Param (
    # Array of double values
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [double[]]$Values
    )
    Begin {
        $count=0.0
        $mean=0.0
        $sum=0.0
    }#begin
 
    Process {
        foreach ($value in $values) {
            ++$count
            $delta = $mean + (($value - $mean) / $count)
            $sum += ($value - $mean) * ($value - $delta)
            $mean = $delta
        }#foreach
    } # process
 
    End {
        $VariancePopulation = $sum/($count)
        $VarianceSample = $sum/($count-1)
        $obj=[PSCustomObject]@{
            "VariancePopulation" = $VariancePopulation
            "VarianceSample" = $VarianceSample
            "STDEVPopulation" = [Math]::Sqrt($VariancePopulation)
            "STDEVSample" = [Math]::Sqrt($VarianceSample)
            "Mean" = $mean
            "Count" = $count
        }#obj
        Write-Output $obj
    } #end
 
}#function
