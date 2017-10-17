function Find-FileWithSignature {
  <#
    .DESCRIPTION
        Looks for file(s) by specific signature.
    .EXAMPLE
        PS C:\>Find-FileWithSignature 'PK'
    .EXAMPLE
        PS C:\>ffws 'MZ' -p E:\Downloads
  #>
  param(
    [Parameter(Mandatory=$true,
               Position=0)]
    [String]$Signature,
    
    [Parameter(Position=1)]
    [String]$PathName = $pwd.Path
  )
  
  $len = $Signature.Length * 3
  gci $PathName | % {
    if (-not $_.PSIsContainer) {
      if ((-join (cat -enc Byte -tot $len $_.FullName | % {[Char]$_})) -match $Signature) {
        Write-Host $_.FullName -fo Magenta
      }
    }
  }
  ""
}
