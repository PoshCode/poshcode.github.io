#ugly way
function Get-RandomPassword {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false)]
    [int]$PasswordLength = "7"
  )

  $rnd = New-Object Random
  $chr = @(33..125)

  for ($i = 0; $i -lt $PasswordLength; $i++) {
    $pas += [char]$chr[$rnd.Next(0, [int]$chr.Length)]
  }

  return $pas
}

#smart way
function Get-RandomPassword {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false)]
    [int]$PasswordLength = "7"
  )
  return -join ([char[]]@(33..125) | Get-Random -count $PasswordLength)
}
