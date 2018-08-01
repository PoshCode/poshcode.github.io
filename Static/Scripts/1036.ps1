&{param([char]$c)[int]$s=65;$p=$c-$s;$r=,(' '*$p+[char]$s);$r+=@(do{"{0,$p} {1}{0}"-f([char]++$s),('  '*$f++)}until(!--$p));$r;$r[-2..-99]}Z

