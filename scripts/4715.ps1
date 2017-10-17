Set-Alias awl Add-AssemblyWithoutLock

function Add-AssemblyWithoutLock {
  param(
    [Parameter(Mandatory=$true)]
    [String]$AssemblyName
  )
  
  if (Test-Path $AssemblyName) {
    [void][Reflection.Assembly]::Load([IO.File]::ReadAllBytes((cvpa $AssemblyName)))
  }
  else {Write-Warning ('assembly {0} does not exist.' -f $AssemblyName)}
}
