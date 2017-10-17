## Write a program which draws a diamond of the form illustrted 
## below. The letter which is to appear at the widest point of the 
## figure (E in the example) is to be specified as the input data.
##           A
##          B B
##         C   C
##        D     D
##       E       E
##        D     D
##         C   C
##          B B
##           A
Param([char]$letter = "E")
$start = [int][char]"B"
$end = [int]$letter

$outerpadding = ($end - $start) + 5
$innerpadding = -1
Write-Host "$(" " * $outerpadding)A"
foreach($char in ([string[]][char[]]($start..$end))) { 
   $innerpadding += 2
   $outerpadding--
   Write-Host "$(" " * $outerpadding)$char$(" " * $innerpadding)$char"
}
$end--
foreach($char in ([string[]][char[]]($end..$start))) { 
   $innerpadding -= 2
   $outerpadding++
   Write-Host "$(" " * $outerpadding)$char$(" " * $innerpadding)$char"
}
Write-Host "$(" " * $outerpadding) A"

