function Test-Assembly {
  param(
    [Parameter(Mandatory=$true)]
    [String]$Assembly
  )
  
  return [Boolean]([AppDomain]::CurrentDomain.GetAssemblies() | ? {
    $_.FullName.Split(',')[0] -eq $Assembly
  })
}
