## WARNING: I take no responsibility for how weird this is.
function Import-UniqueModule { 

param([Parameter(Mandatory=$true)][String]$ModuleName)

$unique = [guid]::NewGuid().Guid -replace "-"
Import-Module $ModuleName -Prefix $unique
Get-Command -Module $ModuleName | 
   New-Alias -Name {$_.Name -replace $unique} -Value { "{0}/{1}" -f $_.ModuleName, $_.name }

}

