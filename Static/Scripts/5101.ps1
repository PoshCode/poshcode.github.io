#looks for drive letters which are used with system at current moment (including subst)
65..90 | % {cmd /c 2`>nul @([Char]$_ + ':') `&`& echo ([Char]$_)}
