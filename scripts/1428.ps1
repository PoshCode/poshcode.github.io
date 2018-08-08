param(
    [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)]
    [string[]]
    $ComputerName
)
 
Process {
    foreach ($cn in $ComputerName) {
        Write-Host "Processing $cn"
    }
}
