&{param([char]$c)[int]$s=65;$p=$c-$s;$r=,(' '*$p+[char]$s);$r+=@(do{"{0,$p} {1}{0}"-f([char]++$s),('  '*$f++)}until(!--$p));$r;$r[-2..-99]}Z

# trimmed 130 chars w/o arg
&{param([char]$c)$p=$c-($s=65);$r=,(' '*$p+[char]$s);do{$r+="{0,$p} {1}{0}"-f([char]++$s),('  '*$f++)}until(!--$p);$r;$r[-2..-99]}J
