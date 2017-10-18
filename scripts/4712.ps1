function Test-Assembly {
  param(
    [Parameter(Mandatory=$true)]
    [String]$Wildcard
  )
  
  if (-not $Wildcard.EndsWith('*')) {$Wildcard += '*'}
  
  return (([AppDomain]::CurrentDomain.GetAssemblies() | ? {
    $_.FullName -like $Wildcard
  }) -ne $null)
}
