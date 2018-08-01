#random subst for current directory
subst (gci function:[a-z]: -n | ? {!(Test-Path $_)} | random) (cvpa .)
