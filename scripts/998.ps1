function Get-VariableType {
    param([string]$Name)
 
    get-variable $name | select -expand attributes | ? {
        $_.gettype().name -eq "ArgumentTypeConverterAttribute" } | % {
        $_.gettype().invokemember("_convertTypes", "NonPublic,Instance,GetField", $null, $_, @())
    }
}
