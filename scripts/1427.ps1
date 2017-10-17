Function Test-Func {

    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)]
        [string[]]$ComputerName
    )
    
    Begin {
        Function Do-Process($p) {
            "Processing $($p)"
        }
    }
    
    Process {
        if($_) { Do-Process $_ }
    }
    
    End {
        if($ComputerName) { @($ComputerName) | % {Do-Process $_} }
    }
}
 
Test-Func a,b
'a','b' | Test-Func
Test-Func x
'x'  | Test-Func
