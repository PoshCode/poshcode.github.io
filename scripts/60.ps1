param([array]$Collection)
 
begin {
    $result = $Seed
    
    if ($args -eq '-?') {
        ''
        'Usage: Select-Random [[-Collection] <array>]'
        ''
        'Parameters:'
        '    -Collection : The collection from which to select a random entry.'
        '    -?          : Display this usage information'
        ''
        'Examples:'
        '    PS> $arr = 1..5; Select-Random $arr'
        '    PS> 1..5 | Select-Random'
        ''
        exit
    } 
 
    $coll = @()
    if ($collection.count -gt 0) { 
        $coll += $collection
    }
}
 
process {
    if ($_) {
        $coll += $_;
    }
}
 
end {
    if ($coll) {
        $randomIndex = Get-Random -Min 0 -Max ($coll.Count)
        $coll[$randomIndex]
    }
}

