#looks for drive letters which are used with system at current moment (including subst)
[Char[]](65..90) | ? {cmd /c 2`>nul @($_ + ':') `&`& echo $_}
