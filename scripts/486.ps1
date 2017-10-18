$word=New-Object -COM "Word.Application"
 
$errorlog="c:\missing.csv"
Set-Content $errorlog "Chapter,Script"
Get-ChildItem c:\test\*.doc | foreach {
    $file=$_.fullname
    Write-Host $file
    $doc=$word.Documents.Open($file) 
    
    $style=$word.ActiveDocument.Styles | 
    where {$_.namelocal -eq "code Title"}
    
    $word.Selection.Find.Style = $style
    
    while ($word.Selection.Find.Execute()) {
        $text=($word.selection.sentences | select Text).text
        $script=(Join-Path "C:\scripts\posh" $text).Trim()
 
         if ((Get-Item $script -ea "silentlycontinue").exists) {
             Write-Host "verified $script"
             Move-Item $script -destination "c:\scripts\posh\ad"
         }
        else {
            $msg="{0},{1}" -f $file,$script
            Add-Content $errorlog $msg
        }
        
     } 
     
     $doc.close()
 
 }
 
$word.quit()

