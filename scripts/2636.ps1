function Get-Scope{
    $rtnScope = 0
    $global:scope = $false
    $scope = $true
    while($($ErrorActionPreference = "silentlycontinue"; switch((get-Variable -Name scope -Scope $rtnScope).value){$null{$true} $true{$true} $false{$ErrorActionPreference = "continue"; return ($rtnScope - 1)}})){
        $rtnScope++
    }
}

Example.

function gg{
    Get-Scope
}; 

function iii{
    gg
}; 

iii    ==> result is 2
