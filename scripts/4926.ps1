#requires -version 2.0
Set-Alias hex2dec Convert-Hex2Dec

function Convert-Hex2Dec {
  <#
    .EXAMPLE
        PS C:\>hex2dec 010, 255, 512, ff, x213, 999999999999999
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String[]]$Number
  )
  
  $Number | % {
    [UInt32]$n = $null
    if ([UInt32]::TryParse($_, [ref]$n)) {
      if (!$_.StartsWith('0')) {'{0} = 0x{1:X}' -f $_, $n}
      else {'Invalid dec: ' + $_}
    }
    else {
      try {
        if ($_.StartsWith('x', [StringComparison]::OrdinalIgnoreCase)) {$_ = '0' + $_}
        '{0} = {1}' -f $_, $([Convert]::ToUInt32($_, 16))
      }
      catch [FormatException]   {'Invalid hex: ' + $_}
      catch [OverflowException] {$_.Exception.Message}
    }
  }
  ''
}
