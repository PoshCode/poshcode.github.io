# Inside Clear-Host
#
# cls is just an alias of function Clear-Host
(Get-Item function:"$((Get-Item alias:cls).Definition)").Definition
# do you not belive your eyes too?
# OK. let's try to locate alternative ways
[Console]::Clear() #looking good, but...
# we can use mode.com utility
[void](mode con:lines=0) # mmm... a lot of symbols
# the shortes way
cmd /c cls
# enjoy :)
