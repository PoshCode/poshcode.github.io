Set-Alias hex2dec Convert-Hex2Dec

function Convert-Hex2Dec {
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String]$Number
  )

  begin {
    function col($c) {$host.UI.RawUI.ForegroundColor = $c}
    $old = $host.UI.RawUI.ForegroundColor
  } 
  process {
    if ($Number -match "^[0-9]+$") {
      if ($Number.Length -gt 1 -and $Number.Substring(0, 1) -eq "0") {
        throw (New-Object System.FormatException)
      }
      col "Magenta";"{0} = 0x{1:X}`n" -f $Number, [Int32]$Number;col $old
    }
    elseif ($Number -match "^(0x|x)|([0-9]|[a-f])+$") {
      col "Cyan"
      try {
        switch ($Number.Substring(0, 1)) {
          "x" {"0x{0} = {1}`n" -f $Number.Substring(1, $Number.Length - 1).ToUpper(), `
                                                                [Int32]("0" + $Number)}
          "0" {"0x{0} = {1}`n" -f $Number.Substring(2, $Number.Length - 2).ToUpper(), `
                                                                        [Int32]$Number}
          default {
            "0x{0} = {1}`n" -f $Number.ToUpper(), [Int32]("0x" + $Number)
          }
        }
      }
      catch {}
      col $old
    }
  }
}
