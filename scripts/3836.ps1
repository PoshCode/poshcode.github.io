function Write-ScriptVariables {
   $globalVars = get-variable -scope Global | % { $_.Name }
   Get-Variable -scope Script | Where-Object { $globalVars -notcontains $_.Name } | Where-Object { $_.Name -ne 'globalVars' } | Out-String	
}

