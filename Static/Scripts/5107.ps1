<#
   Usage sample:
   PS> subst (([Char[]](65..90)|%{if(!(Test-Path($d=$_+':'))){$d}})|random -c 1) (Read-Host 'Enter directory')
   Enter directory: .
   PS> subst
   M:\: => R:\src
#>
subst (([Char[]](65..90)|%{if(!(Test-Path($d=$_+':'))){$d}})|random -c 1) (Read-Host 'Enter directory')
