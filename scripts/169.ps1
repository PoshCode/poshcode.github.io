## Get-WebFile.ps1 (aka wget for PowerShell)
##############################################################################################################
## Downloads a file or page from the web
## History:
## v3 - rewritten completely using HttpWebRequest + HttpWebResponse to figure out the file name, if possible
##############################################################################################################
#function wget {
   param( 
      $url = "http://www.squirrelmail.org/countdl.php?fileurl=http%3A%2F%2Fprdownloads.sourceforge.net%2Fsquirrelmail%2Fsquirrelmail-1.4.13.tar.bz2",
      $fileName
   )
   
   $req = [System.Net.HttpWebRequest]::Create($url);
   $res = $req.GetResponse();

   if($fileName -and !(Split-Path $fileName)) {
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   } 
   elseif(($fileName -eq $null) -or (Test-Path -PathType "Container" $fileName))
   {
#  if( -and !((Test-Path -PathType "Leaf" $fileName) -or ((Test-Path -PathType "Container" (Split-Path $fileName)) -and -not )))
      [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
      $fileName = $fileName.trim("\/")
      if(!$fileName) {
         $fileName = $res.ResponseUri.Segments[-1]
         $fileName = $fileName.trim("\/")
         if(!$fileName) { 
            $fileName = Read-Host "Please provide a file name"
         }
         $fileName = $fileName.trim("\/")
         if(!([IO.FileInfo]$fileName).Extension) {
            $fileName = $fileName + "." + $res.ContentType.Split(";")[0].Split("/")[1]
         }
      }
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   }

   if($res.StatusCode -eq 200) {
      $reader = new-object System.IO.StreamReader $res.GetResponseStream()
      $writer = new-object System.IO.StreamWriter $fileName
      # TODO: stick this in a loop and give progress reports
      $writer.Write($reader.ReadToEnd())
      
      $reader.Close();
      $writer.Close();
   }
   $res.Close(); 
   ls $fileName
#}
