## Page (aka More, aka Page-Output)
###################################################################################################
## This is like a (very simple) "more" script for PowerShell ... 
## The problem with it is that you're paging by a count of objects, not by how many lines of text 
## they'll output ... so the paging doesn't really work except for format-table output ... 
## unless you specify it manually.  
##
## However, this script provides you with "an option" if you want to have paging and still be able
## to do something like using a script to color the output based on context or syntax:
## 
## Simple example:
## ls | Page | % { $_ ; switch( $i++ % 2 ) { 0 { $Host.UI.RawUI.BackgroundColor = "Black" } 1 { $Host.UI.RawUI.BackgroundColor = "DarkGray" } } }
###################################################################################################
## Revision History
## 1.1 - Clean up output (overwrite the prompt)
##     - Add option to stop paging (and also to abort)
## 1.0 - Demo script
###################################################################################################
# function Page {
Param( [int]$count=($Host.UI.RawUI.WindowSize.Height-5) )
   BEGIN {
      $x  = 1
      $bg = $Host.UI.RawUI.BackgroundColor;
      $fg = $Host.UI.RawUI.ForegroundColor;
      $page = $true
   }
   PROCESS {
      if($page -and (($x++ % $count) -eq 0)) {
         Write-Host "Press a key to continue (or 'A' for all, or 'Q' to quit)..." -NoNew;
         $Host.UI.RawUI.FlushInputBuffer();
         $ch = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp");
         switch -regex ($ch.Character){
            "a|A" { $page = $false }
            "q|Q" { exit }
         }
         $pos = $Host.UI.RawUI.CursorPosition;
         $pos.X = 0;
         $Host.UI.RawUI.CursorPosition = $pos;
      }
      $_
   }
   END {
      # Don't forget to set the colors back...
      $Host.UI.RawUI.BackgroundColor = $bg;
      $Host.UI.RawUI.ForegroundColor = $fg;
   }
#}
