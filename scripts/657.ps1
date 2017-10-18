$pathToScripts = "C:\Scripts\*"

foreach($itm in get-childitem $pathToScripts -include *.ps1 -recurse)
  {"{0,-25}{1,0}" -f ((" " + $itm.name) -replace ".ps1",""), ((get-content $itm | where {$_ -like "*Purpose:*"}) -replace "# Purpose: ","")}
