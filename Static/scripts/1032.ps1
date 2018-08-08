&{Param([char]$l)$s=66;$z=[int]$l;$o=$z-$s+ 5;$p=-1;$n=&{"$(" "*$o)A";([string[]][char[]]($s..$z))|%{$p+=2;$o--;"$(" "*$o)$_$(" "*$p)$_"}};$n;$n[$($n.Length-2)..0]}L


