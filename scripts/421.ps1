## Send-Paste (aka sprunge for Pastebin)
##############################################################################################################
## Uploads code to any pastebin.com based pastebin site and returns the url for you.
##############################################################################################################
## Usage:
##    get-content myscript.ps1 | Send-Paste "An example for you" "This is just to show how to do it"
##       would send the script with the specified title and description
##    ls *.ps1 | Send-Paste -Keep Forever
##       would flood the pastebin site with all your scripts, using filename as the title
##       and a generic description, and mark them for storing indefinitely
##    get-history -count 5 | % { $_.CommandLine } | Send-Paste
##       would paste the last 5 commands in your history!
##############################################################################################################
## History:
## v 2.1 - Changed some defaults
##       - Added "PermanentPosh" switch ( -P ) to switch the upload to the PowerShellCentral repository
## v 2.0 - works with "pastebin" (including posh.jaykul.com/p/ and PowerShellCentral.com/scripts/)
## v 1.0 - Worked with a special pastebin
##############################################################################################################
function Send-Paste {
param( 
   $Title, 
   $Description=$(Read-Host "Please enter a description for this script"), 
   $KeepFor="d", 
   $Language="posh", 
   $Author = $(Read-Host "Your name"), 
   $url="http`://posh.jaykul.com/p/",
   [switch]$PermanentPosh
)
   
BEGIN {
   $null = [Reflection.Assembly]::LoadWithPartialName("System.Web")
   [string]$data = $null;
   [string]$meta = $null;

   if($PermanentPosh) {
      $url = "http`://PowerShellCentral.com/scripts/"
      $keepFor = "f"
   }
   
   if($language) {
      $meta = "format=" + [System.Web.HttpUtility]::UrlEncode($language)
      # $url = $url + "?" +$lang
   } else {
      $meta = "format=text"
   }
  
   do {
      switch -regex ($KeepFor) {
         "^d.*" { $meta += "&expiry=d" }
         "^m.*" { $meta += "&expiry=m" }
         "^f.*" { $meta += "&expiry=f" }
         default { 
            $KeepFor = Read-Host "Invalid value for 'KeepFor' parameter. Please specify 'day', 'month', or 'forever'"
         }
      }
   } until ( $meta -like "*&expiry*" )
 
   if($Description) {
      $meta += "&descrip=" + [System.Web.HttpUtility]::UrlEncode($Description)
   } else {
      $meta += "&descrip="
   }   
   $meta += "&poster=" + [System.Web.HttpUtility]::UrlEncode($Author)
   
   function PasteBin-Text ($meta, $title, $data) {
      $meta += "&paste=Send&posttitle=" + [System.Web.HttpUtility]::UrlEncode($Title)
      $data = $meta + "&code2=" + [System.Web.HttpUtility]::UrlEncode($data)
      
      Write-Host $url -fore yellow
      
      $request = [System.Net.WebRequest]::Create($url)
      $request.ContentType = "application/x-www-form-urlencoded"
      $request.ContentLength = $data.Length
      $request.Method = "POST"
 
      $post = new-object IO.StreamWriter $request.GetRequestStream()
      $post.Write($data,0,$data.Length)
      $post.Flush()
      $post.Close()
 
      # $reader = new-object IO.StreamReader $request.GetResponse().GetResponseStream() ##,[Text.Encoding]::UTF8
      # write-output $reader.ReadToEnd()
      # $reader.Close()
      write-output $request.GetResponse().ResponseUri.AbsoluteUri
      $request.Abort()      
   }
}
PROCESS {
   switch($_) {
      { $_ -is [System.IO.FileInfo] } {
         if(!$Title) {
            if ($_.Extension.Length -gt 0)
            { 
               $Title = $_.Name.Remove($_.Name.Length - $_.Extension.Length) 
            } else { 
               $Title = $_.Name 
            }
         }
         Write-Output $_.FullName
         Write-Output $(PasteBin-Text $meta $Title $([string]::join("`n",(Get-Content $_.FullName))))
      }
      { $_ -is [String] } {
         if(!$data -and !$Title){
            $Title = Read-Host "Give us a title for your post"
         }
         $data += "`n" + $_ 
      }
      ## Todo, handle folders?
      default {
         Write-Error "Unable to process $_"
      }
   }
}
END {
   if($data) { 
      Write-Output $(PasteBin-Text $meta $Title $data)
   }
}
}
 
## Find-Paste (search Pastebin)
##############################################################################################################
## Searches the powershellcentral.com/script site and returns lists of results
## All search terms are automatically surrounded with wildcards
## NOTE: powershellcentral.com currently uses MySql fulltext search syntax...
##############################################################################################################
## Usage:
##    find-paste crypt
##       would find scripts about encryption, decryption, cryptography, etc.
##############################################################################################################
## History:
## v 1.0 - Working against our special pastebin
##############################################################################################################
function Find-Paste {
   param(
      [string]$query,
      $url="http`://powershellcentral.com/scripts/"
   )
   
   $page = Get-WebFile "$($url)?q=*$($query)*" -passthru
   
   $start = $page.IndexOf("<body")
   $length = $page.indexOf("</html") - $start
   $doc = [xml]$page.Substring($start,$length)
   $doc.SelectNodes( "//div[@id='content']/*/tr[position() > 1]" ) |
   % { 
      Select @{n="Id";e={$_.td[0].a.href -replace $url,''}},
                      @{n="Title";e={$_.td[0].a."#text"}},
                      @{n="Description";e={$_.td[3]}},
                      @{n="Author";e={$_.td[1]}},
                      @{n="Date";e={$_.td[2]}},
                      @{n="Link";e={$_.td[0].a.href}} -Input $_ 
   }
}
 
## Get-Paste (download Pastebin script)
##############################################################################################################
## Downloads a specified script from a Pastbin.com based site, by Id
##############################################################################################################
## Usage:
##    Get-Paste 184
##       would download the original Get-Paste script to 184.ps1
##    Get-Paste 184 -Passthru
##       would output the contents of Get-Paste to the pipeline
##    Get-Paste 184 Get-Paste.ps1
##       would download Get-Paste to Get-Paste.ps1 in the current directory
##############################################################################################################
## History:
## v 1.0 - Working against our special pastebin
##############################################################################################################
function Get-Paste {
   param(
      [int]$Id = (throw "You must specify the id of the paste to get"),
      [string]$SaveAs,
      [switch]$InBrowser,
      [switch]$Passthru,
      $url="http`://powershellcentral.com/scripts/"
   )
   if(!$InBrowser) {
      if($SaveAs) {
         Get-WebFile "$($url)?dl=$id" -fileName $SaveAs
      } elseif($Passthru) {
         Get-WebFile "$($url)?dl=$id" -Passthru
      } else {
         Get-WebFile "$($url)?dl=$id"
      }
   } else {
      [Diagnostics.Process]::Start( "$($url)$id" )
   }
}
 

## Get-WebFile (aka wget for PowerShell)
##############################################################################################################
## Downloads a file or page from the web
## History:
## v3.6 - Add -Passthru switch to output TEXT files 
## v3.5 - Add -Quiet switch to turn off the progress reports ...
## v3.4 - Add progress report for files which don't report size
## v3.3 - Add progress report for files which report their size
## v3.2 - Use the pure Stream object because StreamWriter is based on TextWriter:
##        it was messing up binary files, and making mistakes with extended characters in text
## v3.1 - Unwrap the filename when it has quotes around it
## v3   - rewritten completely using HttpWebRequest + HttpWebResponse to figure out the file name, if possible
## v2   - adds a ton of parsing to make the output pretty
##        added measuring the scripts involved in the command, (uses Tokenizer)
##############################################################################################################
function Get-WebFile {
   param( 
      $url = (Read-Host "The URL to download"),
      $fileName = $null,
      [switch]$Passthru,
      [switch]$quiet
   )
   
   $req = [System.Net.HttpWebRequest]::Create($url);
   $res = $req.GetResponse();
 
   if($fileName -and !(Split-Path $fileName)) {
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   } 
   elseif((!$Passthru -and ($fileName -eq $null)) -or (($fileName -ne $null) -and (Test-Path -PathType "Container" $fileName)))
   {
      [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
      $fileName = $fileName.trim("\/""'")
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
   if($Passthru) {
      $encoding = [System.Text.Encoding]::GetEncoding( $res.CharacterSet )
      [string]$output = ""
   }
 
   if($res.StatusCode -eq 200) {
      [int]$goal = $res.ContentLength
      $reader = $res.GetResponseStream()
      if($fileName) {
         $writer = new-object System.IO.FileStream $fileName, "Create"
      }
      [byte[]]$buffer = new-object byte[] 4096
      [int]$total = [int]$count = 0
      do
      {
         $count = $reader.Read($buffer, 0, $buffer.Length);
         if($fileName) {
            $writer.Write($buffer, 0, $count);
         } 
         if($Passthru){
            $output += $encoding.GetString($buffer,0,$count)
         } elseif(!$quiet) {
            $total += $count
            if($goal -gt 0) {
               Write-Progress "Downloading $url" "Saving $total of $goal" -id 0 -percentComplete (($total/$goal)*100)
            } else {
               Write-Progress "Downloading $url" "Saving $total bytes..." -id 0
            }
         }
      } while ($count -gt 0)
      
      $reader.Close()
      if($fileName) {
         $writer.Flush()
         $writer.Close()
      }
      if($Passthru){
         $output
      }
   }
   $res.Close(); 
   if($fileName) {
      ls $fileName
   }
}
