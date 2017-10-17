## Get-Sequence
## Optionless implementation of seq for PowerShell
############################################################################
## Most of the options don't apply because they convert the numbers to text
##   which isn't something a PowerShell Seq wants to do :)
############################################################################
## Usage:  
##   seq $LAST
##   seq $FIRST $LAST 
##   seq $FIRST $INTERVAL $LAST 
############################################################################
function Get-Sequence{
 switch($args.Count){ 
   1 {[int]$first=0;        [int]$inc=1;        [int]$last=$args[0]}
   2 {[int]$first=$args[0]; [int]$inc=1;        [int]$last=$args[1]}
   3 {[int]$first=$args[0]; [int]$inc=$args[1]; [int]$last=$args[2]}
 }
 if($inc-gt0){
   while($first-le$last){$first;$first+=$inc}
 } else {
   while($first-ge$last){$first;$first+=$inc}
 }
}

## Set the default alias
New-Alias seq Get-Sequence

############################################################################
############################################################################
## EXAMPLE SCRIPT:
## Original Bash Script using Gnome's Notify-Send for libnotify
# s=.o0O0o.o0O0o.o0O0o.o0O0o.o0O0o.o0O0o.o0;n(){ for x in `seq $1 $2 $3`;do notify-send ${s:0:x}; done };while :;do n 1 2 39;n 39 -2 1;done

## PowerShell Script using Send-Notice for Growl
## BUT, if you don't have Growl and Send-Notice, just use this instead:
New-Alias Send-Notice Write-Progress

## And then you can:  (note that in the sample there's no end case, you have to CTRL+C)
# $s=".o0O0o.o0O0o.o0O0o.o0O0o.o0O0o.o0O0o.o0";function n{$ofs="";foreach($x in $(seq @args)){Send-Notice "Working" "$($s[0..$x])"}}while(1){n 1 2 39;n 39 -2 1}


