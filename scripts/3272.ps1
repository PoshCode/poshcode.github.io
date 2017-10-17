function Convert-ToCHexString {
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline=$true,Mandatory=$true)][string]$str
)    
   process { ($str.ToCharArray() | %{ "0x{0:X2}" -f [int]$_  }) -join ',' }
}
