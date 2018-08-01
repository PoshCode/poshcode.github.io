#.Synopsis
#  Calculate statistics about files
#.Description
#  A lightweight simulation of unix's "wc" word count application
#.Parameter $file
#  Accepts PIPELINE input
#  The file name(s) or wildcard patterns for the file(s) you want to count
#.Example
#  wc *.ps1
#
#  Calculates line, word, and character counts for powershell script files in the current directory.
#.Example
#  wc *.ps1, *.psm1, *.psd1
#  
#  Calculates line, word, and character counts for powershell script and module files
#
function Measure-File { 
Param([string[]]$file)
PROCESS{
   if(!$file -and $_)
   {$file = $_}
   # wrap it with get-childitem so we do each file...
   foreach($f in ls $file){
      gc $f -delim [char]0|
      measure -line -word -char |
      select Lines, Words, Characters, @{n="Name";e={$f.Name}}
   }
}} 
new-alias wc measure-file

