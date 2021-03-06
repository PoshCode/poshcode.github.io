## DekiWiki Module -note this is a v2 module, but I think you can dot-source in v1 if you remove the last line ;)
####################################################################################################
## The first of many script cmdlets for working with DekiWiki, based on their REST api sdk "Dream"
## You need log4net.dll mindtouch.core.dll mindtouch.dream.dll and SgmlReaderDll.dll from the SDK
## Download DREAM from http://sourceforge.net/project/showfiles.php?group_id=173074 
## Unpack it, and you can find these dlls in the "dist" folder.
####################################################################################################
## More details to come with the next version. Sorry, it's time for bed ;)
## History:
## v 1.0 Set-DekiCredential, Get-DekiContent, Set-DekiContent, New-DekiContent, Get-DekiFile
## 

[Reflection.Assembly]::LoadFile( "$PSScriptRoot\mindtouch.dream.dll" )

$url = "http://powershell.wik.is" # 
$api = "$url/@api/deki"
$plug = [MindTouch.Dream.Plug]::New($api);  
$cred = $null

function Set-DekiCredential {
   param($Credential=$(Get-Credential))
   $global:cred = $Credential
}

function Get-DekiCredential {
   if(!$global:cred) { Set-DekiCredential $(Get-Credential) }
   return $global:cred.GetNetworkCredential();
}


$DreamText = [MindTouch.Dream.MimeType]::TEXT
$DreamXml  = [MindTouch.Dream.MimeType]::XML
$DreamHtml  = [MindTouch.Dream.MimeType]::HTML
function Get-DekiContent {
   param( $pageName = "Test_Page" )
   $pageName = [System.Web.HttpUtility]::UrlEncode( [System.Web.HttpUtility]::UrlEncode( $pageName ) )
   
   $plug.At("pages", "=$pageName", "contents").With("mode", "view").Get().AsDocument().AsXmlNode
}

# Get-DekiFile will LIST all files if called with just a PageName
# Otherwise, fileName can be a single fileName, or wildcards
function Get-DekiFile {
   param( $pageName = "Test_Page", [string[]]$fileNames, $destinationFolder )
   $encodedPageName = Encode-Twice $pageName
   
   $files = $plug.At("pages", "=$encodedPageName", "files").Get().AsDocument().AsXmlNode.file

   if(!$fileNames) {
      return $files
   } else {   
      foreach($fileName in $fileNames) {
         foreach($file in $($files | where { $_.filename -like $fileName } )) {
            $encodedFileName = [System.Web.HttpUtility]::UrlEncode( [System.Web.HttpUtility]::UrlEncode( $($file.filename) ) )
            Write-Verbose "Fetching $($file.filename) from $pageName"
            # Note that you can resize, if it's a picture: .With("size", "bestfit").With("width", 100).With("height", 100).Get();  
            $message = $plug.At("pages", "=$encodedPageName", "files", "=$encodedFileName").Get()
            $fullName = $(Get-FileName $file.filename destinationFolder)
            &{
               $writer = new-object System.IO.FileStream $fullName, "Create"
               $bytes = $message.AsBytes()
               $writer.Write($bytes,0,$bytes.Length)
               trap { 
                  $writer.Flush()
                  $writer.Close() 
               }
               $writer.Flush()
               $writer.Close()
               
            }
            write-output (get-item $fullName)
         }
      }
   }
}

function Set-DekiContent {
   param( $pageName = "Test_Page", $content = (throw "You must specify page contents"), $section )
   $encodedPageName = Encode-Twice $pageName 
   # you have to pre-authenticate ...
   $null = $plug.At("users", "authenticate").WithCredentials( $(Get-DekiCredential) ).Get()

   if( $content -is [System.Xml.XmlDocument]) {
      $msg = [MindTouch.Dream.DreamMessage]::Ok( $content )
   } else { 
      $msg = [MindTouch.Dream.DreamMessage]::Ok( $DreamText, $content )
   }
   Write-Verbose "Updating $pageName at $(UtcNow "yyyyMMddhhmmss"): $($msg.ContentLength) bytes"
   Write-Verbose "$($msg.AsText())"
   $partway = $plug.At("pages", "=$encodedPageName", "contents").With("edittime",$(UtcNow "yyyyMMddhhmmss"))
   if($section) {
      $result = $partway.With("Section",0).Post( $msg )
   } else {
      $result = $partway.Post( $msg )
   }
   if($result.IsSuccessful) {
      return "$url/$pageName"
   } else {
      return $result.Response
   }


   trap [MindTouch.Dream.DreamResponseException] {
      Write-Error "TRAPPED DreamResponseException`n`n$($_.Exception.Response | Out-String)`n`n`n$($_.Exception.Response.Headers | Out-String)"
      break;
   }
   
}


function New-DekiContent {
   param( $pageName = "Test_Page", $content = (throw "You must specify page contents") )
   $encodedPageName = Encode-Twice $pageName
   # you have to pre-authenticate ...
   $null = $plug.At("users", "authenticate").WithCredentials( $(Get-DekiCredential) ).Get()
   
   if( $content -is [System.Xml.XmlDocument]) {
      $msg = [MindTouch.Dream.DreamMessage]::Ok( $content )
   } else { 
      $msg = [MindTouch.Dream.DreamMessage]::Ok( $DreamText, $content )
   }
   Write-Verbose "Updating $pageName at $(UtcNow "yyyyMMddhhmmss"): $($msg.ContentLength) bytes"
   Write-Verbose "$($msg.AsText())"
   
   $result = $plug.At("pages", "=$encodedPageName", "contents").With("abort", "exists").With("edittime",$(UtcNow "yyyyMMddhhmmss")).Post( $msg )  
   trap [MindTouch.Dream.DreamResponseException] {
      Write-Error "TRAPPED DreamResponseException`n`n$($_.Exception.Response | Out-String)`n`n`n$($_.Exception.Response.Headers | Out-String)"
   }
   if($result.IsSuccessful) {
      return "$url/$pageName"
   } else {
      return $result.Response
   }
}

## Utility Functions 
function UtcNow {
   Param($Format="")
   [DateTime]::Now.ToUniversalTime().ToString($Format)
}
function Encode-Twice {
   param([string]$text)
   return [System.Web.HttpUtility]::UrlEncode( [System.Web.HttpUtility]::UrlEncode( $text ) )
}

function Get-FileName {
   param($fileName=$([IO.Path]::GetRandomFileName()), $path)
   
   $fileName = $fileName.trim("\/""'")
   if($path -and (Test-Path $path)){
      $fileName = Split-Path $fileName -leaf
      Join-Path $path $fileName
   } elseif((Split-Path $fileName) -and (Test-Path (Split-Path $fileName))) {
      return $fileName
   } else {
      Join-Path (Convert-Path (Get-Location -PSProvider "FileSystem")) (Split-Path $fileName -Leaf)
   }
}

Export-ModuleMember Set-DekiCredential, Get-DekiContent, Set-DekiContent, New-DekiContent, Get-DekiFile

