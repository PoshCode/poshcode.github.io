#function ConvertFrom-Hashtable {
[CmdletBinding()]
   PARAM(
      [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
      [HashTable]$hashtable
   ,
      [switch]$Combine
   ,
      [switch]$Recurse
   )
   BEGIN {
      $output = @()
   }
   PROCESS {
      if($recurse) {
         $keys = $hashtable.Keys | ForEach-Object { $_ }
         Write-Verbose "Recursing $($Keys.Count) keys"
         foreach($key in $keys) {
            if($hashtable.$key -is [HashTable]) {
               $hashtable.$key = ConvertFrom-Hashtable $hashtable.$key -Recurse # -Combine:$combine
            }
         }
      }
      if($combine) {
         $output += @(New-Object PSObject -Property $hashtable)
         Write-Verbose "Combining Output = $($Output.Count) so far"
      } else {
         New-Object PSObject -Property $hashtable
      }
   }
   END {
      if($combine -and $output.Count -gt 1) {
         Write-Verbose "Combining $($Output.Count) cached outputs"
         $output | Join-Object
      } else {
         $output
      }
   }
#}
