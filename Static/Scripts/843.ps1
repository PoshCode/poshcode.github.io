function print-file($file)
{
 begin  {               
    function internal-printfile($thefile)
    {    
        if ($thefile -is [string]) {$filename = $thefile } 
        else { 
                if ($thefile.FullName -is [string] ) { $filename = $THEfile.FullName } 
             }   
        $start = new-object System.Diagnostics.ProcessStartInfo $filename
        $start.Verb = "print"
        [System.Diagnostics.Process]::Start($start)                     
    }
    
if ($file -ne $null) {
                $filespecified = $true;
                internal-printfile $file
            }
       }     
process{if (!$filespecified) { write-Host process ; internal-printfile $_ } }

}
