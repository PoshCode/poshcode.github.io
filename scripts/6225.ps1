<#
   Tested on files over 10Mb =)
   Thanks to alpap, Dragokas and greg zakharov for this trick
#>
sort.exe /+$([Int32]::MaxValue) .\file|Out-File reversed.txt -Encoding Default
