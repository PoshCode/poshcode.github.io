function Test-DigitalSignature {
  <#
    .DESCRIPTION
        Checks digital signatures of file(s) via "path" variable.
    .EXAMPLE
        PS C:\>Test-DigitalSignature sigcheck
    .EXAMPLE
        PS C:\>tds sh*
  #>
  param(
    [Parameter(Mandatory=$true)]
    [String]$Wildcard
  )
  
  $get = gcm -ea 0 -c Application $Wildcard
  
  if ($get -ne $null) {
    if ($get -is [Array]) {
      $res = $get | % {Get-AuthenticodeSignature $_.Definition}
    }
    else {$res = Get-AuthenticodeSignature $get.Definition}
  }
  
  $res | select Path, Status | ft -a
}
