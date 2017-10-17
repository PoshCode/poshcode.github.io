function Get-CryptoBytes {
#.Synopsis
#  Generate Cryptographically Random Bytes
#.Description
#  Uses RNGCryptoServiceProvider to generate arrays of random bytes
#.Parameter Count
#  How many bytes to generate
#.Parameter AsString
#  Output hex-formatted strings instead of byte arrays
param(
   [Parameter(ValueFromPipeline=$true)]
   [int[]]$count = 64
,
   [switch]$AsString
)

begin {
   $RNGCrypto = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
   $OFS = ""
}
process {
   foreach($length in $count) {
      $bytes = New-Object Byte[] $length
      $RNGCrypto.GetBytes($bytes)
      if($AsString){
         Write-Output ("{0:X2}" -f $bytes)
      } else {
         Write-Output $bytes
      }
   }
}
end {
   $RNGCrypto = $null
}
}


