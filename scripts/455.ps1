## Join
## Joins array elements together using a specific string separator
############################################
## Usage:
##   $Env:Path = ls | ? {$_.PSIsContainer} | Select -expand FullName | Join ";" -Append $Env:Path
##   get-process | select -expand name | join ","
##

function join { 
   param    ( [string]$sep, [string]$append, [string]$prepend )
   begin    { $ofs = $sep; [string[]]$items =  @($prepend.split($sep)) }
   process  { $items += $_ }
   end      { $items += $append.split($sep); return "$($items -ne '')" }
}
