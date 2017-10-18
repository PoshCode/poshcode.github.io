function invoke-caretline
{
invoke-expression $([Regex]::Split($psISE.CurrentOpenedFile.Editor.text,"`r`n" )[$psISE.CurrentOpenedFile.Editor.caretline-1])
}
$psISE.CustomMenu.Submenus.Add("Run single line", {invoke-caretline} ,  'f7')
function invoke-region([int] $num)
{
$ed = $psISE.CurrentOpenedFile.Editor
$lines = [Regex]::Split($ed.text,"`r`n" )
$foundfirst = -1
$foundlast = -1
for($count = 0;$count -le $lines.length-1;$count++)
 {
   if ($lines[$count].startswith("#region") -and $lines[$count].contains("@$num")) 
   { $foundfirst = $count;break}     
 }
 if($foundfirst -gt -1)
 {
 for ($count = $foundfirst; $count -le $lines.length-1;$count++)
    {    
    if ($lines[$count].startswith("#endregion") )
   { $foundlast = $count;break}     
    }
    
 if ($foundlast -gt -1)
   {
     $torun = ""
     $lines[$foundfirst..$foundlast] | % { $torun+=$_ + "`r`n"}
     invoke-expression $torun
   }
 }
 
}
 $psISE.CustomMenu.Submenus.Add("run region 1", {invoke-region 1 },  'ctrl+1') 
 $psISE.CustomMenu.Submenus.Add("run region 2", {invoke-region 2 },  'ctrl+2') 
 $psISE.CustomMenu.Submenus.Add("run region 3", {invoke-region 3 },  'ctrl+3') 
 $psISE.CustomMenu.Submenus.Add("run region 4", {invoke-region 4 },  'ctrl+4') 
 $psISE.CustomMenu.Submenus.Add("run region 5", {invoke-region 5 },  'ctrl+5') 
