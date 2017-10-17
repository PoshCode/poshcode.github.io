#requires -version 2.0
function Set-RandomFile {
  param(
    [Parameter(Mandatory=$true,
               Position=0)]
    [String]$Path,
    
    [Parameter(Position=1)]
    [ValidateRange(0, 31)]
    [Int32]$Length = 7
  )
  
  begin {
    $ext = cmd /c assoc | % {if ($_ -match '=\w+' -and $_ -notmatch '.\d+=') {$_.Split('=')[0]}}
    $itm = -join ([GUID]::NewGuid().Guid -replace '-', '')[0..$Length]
  }
  process {
    $rnd = Get-Random -max ($ext.Length - 1)
  }
  end{
    if (Test-Path $Path) {
      [void](ni -p $Path -n $($itm + $ext[$rnd]) -t File -fo)
    }
  }
}
