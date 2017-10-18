## You'll want to dot-source this into your script
## To change colors, specify the parameters: 
##  . Scripts\OutWorkingScript.ps1 "Yellow" "Blue"
##
## Then you can show progress like this:
##
## $x = 1..50 | out-working 50
##
## Notice that the $wait parameter is only needed if there will not
##  be enough of a delay already (it just slows the loop down)
##

param($fore="White",$back="red")
$work = @( $Host.UI.RawUI.NewBufferCellArray(@("|"),$fore,$back),
           $Host.UI.RawUI.NewBufferCellArray(@("/"),$fore,$back),
           $Host.UI.RawUI.NewBufferCellArray(@("-"),$fore,$back),
           $Host.UI.RawUI.NewBufferCellArray(@("\"),$fore,$back) );

[int]$script:w = 0;

filter out-working($wait=0) {
   $cur = $Host.UI.RawUI.Get_CursorPosition(); 
   $cur.X = 0; $cur.Y -=1;
   $Host.UI.RawUI.SetBufferContents($cur,$work[$script:w++]);
   if($script:w -gt 3) {$script:w = 0 }
   Start-Sleep -milli $wait
   $_
}            


