#.Synopsis
# Joins array elements together using a specific string separator
#.Example
#   $Env:Path = ls | ? {$_.PSIsContainer} | Select -expand FullName | Join ";" -Append $Env:Path
#.Example
#   get-process | select -expand name | join ","
#

function Join-String { 
   param    ( [string]$separator, [string]$append, [string]$prepend, [string]$prefix, [string]$postfix, [switch]$unique )
   begin    { [string[]]$items =  @($prepend.split($separator)) }
   process  { $items += $_ }
   end      { 
      $ofs = $separator; 
      $items += @($append.split($separator)); 
      if($unique) {
         $items  = $items | Select -Unique
      }
      return "$prefix$($items -ne '')$postfix"
   }
}
