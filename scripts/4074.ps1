<#
   Required v2.0
   Using examples:
      PS C:\> gi .\foo | hex -b 150
      Dumps first 150 bytes of foo.

      PS C:\> hex .\foo -b 150
      It's equal first command.
#>

function Get-HexDump {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [string]$FileName,

    [Parameter(Position=1, Mandatory=$false)]
    [int]$Bytes = -1
  )

  $ofs = ''
  Get-Content -ea 0 -enc Byte $FileName -re 16 -to $Bytes | % {
    $hex = ''; $hex += $_ | % {' ' + ('{0:x}' -f $_).PadLeft(2, "0")}
    $chr = ''; $chr += $_ | % {if ([char]::IsLetterOrDigit($_)) {[char]$_} else {'.'}}
    '{0, -49} {1}' -f $hex, $chr
  }
}


Set-Alias hex Get-HexDump

