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
Param([char]$letter = "E", [int]$padding=5)
$start = [int][char]"B"
$end = [int]$letter

$outerpadding = ($end - $start) + $padding
$innerpadding = -1

$lines = &{ 
   "$(" " * $outerpadding)A"
   foreach($char in ([string[]][char[]]($start..$end))) { 
      $innerpadding += 2; $outerpadding--
      "$(" " * $outerpadding)$char$(" " * $innerpadding)$char"
   }
}

$lines
$lines[$($lines.Length-2)..0]

