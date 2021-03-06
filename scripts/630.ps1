
#Requires -version 1.0
## New-PoshCode (formerly Send-Paste)
##############################################################################################################
## Uploads code to the PowerShell Script Repository and returns the url for you.
##############################################################################################################
## Usage:
##    get-content myscript.ps1 | New-PoshCode "An example for you" "This is just to show how to do it"
##       would send the script with the specified title and description
##    ls *.ps1 | New-PoshCode -Keep Forever
##       would flood the pastebin site with all your scripts, using filename as the title
##       and a generic description, and mark them for storing indefinitely
##    get-history -count 5 | % { $_.CommandLine } | New-PoshCode
##       would paste the last 5 commands in your history!
##############################################################################################################
## History:
## v 3.0 - Renamed to New-PoshCode.  
##         Removed the -Permanent switch, since this is now exclusive to the permanent repository
##
## v 2.1 - Changed some defaults
##       - Added "PermanentPosh" switch ( -P ) to switch the upload to the PowerShellCentral repository
## v 2.0 - works with "pastebin" (including posh.jaykul.com/p/ and PowerShellCentral.com/scripts/)
## v 1.0 - Worked with a special pastebin
##############################################################################################################
# Set-StrictMode -Version Latest
$version = 1
$PoshCodeRepository = Add-Member -in "http://PoshCode.org/" -type NoteProperty -Name "UserName" -Value "Anonymous" -Passthru

function New-PoshCode {
param( 
   $Title, 
   $Description=$(Read-Host "Please enter a description for this script"), 
   $KeepFor="f", 
   $Language="posh", 
   $Author = $($PoshCodeRepository.UserName), 
   $url= $($PoshCodeRepository)
)
   
BEGIN {
   $null = [Reflection.Assembly]::LoadWithPartialName("System.Web")
   [string]$data = $null;
   [string]$meta = $null;
   
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
   
   function Send-PoshCode ($meta, $title, $data, $url= $($PoshCodeRepository)) {
      $meta += "&paste=Send&posttitle=" + [System.Web.HttpUtility]::UrlEncode($Title)
      $data = $meta + "&code2=" + [System.Web.HttpUtility]::UrlEncode($data)
     
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
         Write-Verbose $_.FullName
         Write-Output $(Send-PoshCode $meta $Title $([string]::join("`n",(Get-Content $_.FullName))))
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
      Write-Output $(Send-PoshCode $meta $Title $data)
   }
}
}
 
## Get-PoshCode (download Repository script)
##############################################################################################################
## Downloads a specified script from a Pastbin.com based site, by Id
## ### OR ###
## Searches the powershellcentral.com/script site and returns lists of results
## All search terms are automatically surrounded with wildcards
## NOTE: powershellcentral.com currently uses MySql fulltext search syntax...
##############################################################################################################
## Usage:
##    Get-PoshCode 184
##       would download the original Get-PoshCode script to 184.ps1
##    Get-PoshCode 184 -Passthru
##       would output the contents of Get-PoshCode to the pipeline
##    Get-PoshCode 184 Get-PoshCode.ps1
##       would download Get-PoshCode to Get-PoshCode.ps1 in the current directory
##############################################################################################################
## History:
## v 1.0 - Working against our special pastebin
##############################################################################################################
function Get-PoshCode {
   param(
      [string]$query = (throw "You must specify a query string, or the id of the paste to get"),
      [string]$SaveAs,
	  [switch]$QueryIsID,
      [switch]$InBrowser,
      [switch]$Passthru,
      $url= $($PoshCodeRepository)
   )
   if($QueryIsID){$id = $query -as [int]}
   
   if(!$id) {
         ([xml](Get-WebFile "$($url)api$($version)/*$($query)*" -passthru)).rss.channel.item |
         Select @{n="Id";e={($_.link -replace $url,'') -as [int]}},
                @{n="Title";e={$_.title }},
                @{n="Author";e={$_.creator }},
                @{n="Date";e={$_.pubDate }},
                @{n="Link";e={$_.link }},
                @{n="Description";e={"$($_.description.get_InnerText())" }}
   } else {
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
   
   
    ################## Added by Dmitry Sotnikov ##############################################
	# The next 3 lines are required if your network has a proxy server
	$req.Credentials = [System.Net.CredentialCache]::DefaultCredentials
	if($req.Proxy -ne $null) 	{
		$req.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	}
    ################## Added by Dmitry Sotnikov ##############################################
   
   $res = $req.GetResponse();
 
   if($fileName -and !(Split-Path $fileName)) {
      $fileName = Join-Path (Get-Location -PSProvider "FileSystem") $fileName
   } 
   elseif((!$Passthru -and ($fileName -eq $null)) -or (($fileName -ne $null) -and (Test-Path -PathType "Container" $fileName)))
   {
      [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $res.Headers["Content-Disposition"] ).Groups[1].Value
      $fileName = $fileName.trim("\/""'")
      $ofs = ""
      $fileName = [Regex]::Replace($fileName, "[$([Regex]::Escape(""$([System.IO.Path]::GetInvalidPathChars())$([IO.Path]::AltDirectorySeparatorChar)$([IO.Path]::DirectorySeparatorChar)""))]", "_")
      $ofs = " "

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
      if( ([IO.Path]::GetExtension($fileName) -eq ".ps1") -and 
      ((get-content $fileName) -match "Export-ModuleMember") )
      { 
         $oldFile  = $fileName
         $fileName = [IO.Path]::ChangeExtension($fileName,".psm1")
         Move-Item $oldFile $fileName
      }
      ls $fileName
   }
}
# SIG # Begin signature block
# MIIVBgYJKoZIhvcNAQcCoIIU9zCCFPMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuARGZtezywbfvagd5AQuTquY
# AYugghEMMIIDejCCAmKgAwIBAgIQOCXX+vhhr570kOcmtdZa1TANBgkqhkiG9w0B
# AQUFADBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xKzAp
# BgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EwHhcNMDcw
# NjE1MDAwMDAwWhcNMTIwNjE0MjM1OTU5WjBcMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xNDAyBgNVBAMTK1ZlcmlTaWduIFRpbWUgU3RhbXBp
# bmcgU2VydmljZXMgU2lnbmVyIC0gRzIwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
# AoGBAMS18lIVvIiGYCkWSlsvS5Frh5HzNVRYNerRNl5iTVJRNHHCe2YdicjdKsRq
# CvY32Zh0kfaSrrC1dpbxqUpjRUcuawuSTksrjO5YSovUB+QaLPiCqljZzULzLcB1
# 3o2rx44dmmxMCJUe3tvvZ+FywknCnmA84eK+FqNjeGkUe60tAgMBAAGjgcQwgcEw
# NAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJpc2ln
# bi5jb20wDAYDVR0TAQH/BAIwADAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# LnZlcmlzaWduLmNvbS90c3MtY2EuY3JsMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MA4GA1UdDwEB/wQEAwIGwDAeBgNVHREEFzAVpBMwETEPMA0GA1UEAxMGVFNBMS0y
# MA0GCSqGSIb3DQEBBQUAA4IBAQBQxUvIJIDf5A0kwt4asaECoaaCLQyDFYE3CoIO
# LLBaF2G12AX+iNvxkZGzVhpApuuSvjg5sHU2dDqYT+Q3upmJypVCHbC5x6CNV+D6
# 1WQEQjVOAdEzohfITaonx/LhhkwCOE2DeMb8U+Dr4AaH3aSWnl4MmOKlvr+ChcNg
# 4d+tKNjHpUtk2scbW72sOQjVOCKhM4sviprrvAchP0RBCQe1ZRwkvEjTRIDroc/J
# ArQUz1THFqOAXPl5Pl1yfYgXnixDospTzn099io6uE+UAKVtCoNd+V5T9BizVw9w
# w/v1rZWgDhfexBaAYMkPK26GBPHr9Hgn0QXF7jRbXrlJMvIzMIIDxDCCAy2gAwIB
# AgIQR78Zld+NUkZD99ttSA0xpDANBgkqhkiG9w0BAQUFADCBizELMAkGA1UEBhMC
# WkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIGA1UEBxMLRHVyYmFudmlsbGUx
# DzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhhd3RlIENlcnRpZmljYXRpb24x
# HzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcgQ0EwHhcNMDMxMjA0MDAwMDAw
# WhcNMTMxMjAzMjM1OTU5WjBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNp
# Z24sIEluYy4xKzApBgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpyrKkzM0grwp9
# iayHdfC0TvHfwQ+/Z2G9o2Qc2rv5yjOrhDCJWH6M22vdNp4Pv9HsePJ3pn5vPL+T
# rw26aPRslMq9Ui2rSD31ttVdXxsCn/ovax6k96OaphrIAuF/TFLjDmDsQBx+uQ3e
# P8e034e9X3pqMS4DmYETqEcgzjFzDVctzXg0M5USmRK53mgvqubjwoqMKsOLIYdm
# vYNYV291vzyqJoddyhAVPJ+E6lTBCm7E/sVK3bkHEZcifNs+J9EeeOyfMcnx5iIZ
# 28SzR0OaGl+gHpDkXvXufPF9q2IBj/VNC97QIlaolc2uiHau7roN8+RN2aD7aKCu
# FDuzh8G7AgMBAAGjgdswgdgwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC52ZXJpc2lnbi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBBBgNV
# HR8EOjA4MDagNKAyhjBodHRwOi8vY3JsLnZlcmlzaWduLmNvbS9UaGF3dGVUaW1l
# c3RhbXBpbmdDQS5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgEGMCQGA1UdEQQdMBukGTAXMRUwEwYDVQQDEwxUU0EyMDQ4LTEtNTMwDQYJKoZI
# hvcNAQEFBQADgYEASmv56ljCRBwxiXmZK5a/gqwB1hxMzbCKWG7fCCmjXsjKkxPn
# BFIN70cnLwA4sOTJk06a1CJiFfc/NyFPcDGA8Ys4h7Po6JcA/s9Vlk4k0qknTnqu
# t2FB8yrO58nZXt27K4U+tZ212eFX/760xX71zwye8Jf+K9M7UhsbOCf3P0owggS/
# MIIEKKADAgECAhBBkaFaOXjfz0llZjgdTHXCMA0GCSqGSIb3DQEBBQUAMF8xCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjE3MDUGA1UECxMuQ2xh
# c3MgMyBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0w
# NDA3MTYwMDAwMDBaFw0xNDA3MTUyMzU5NTlaMIG0MQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5l
# dHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJp
# c2lnbi5jb20vcnBhIChjKTA0MS4wLAYDVQQDEyVWZXJpU2lnbiBDbGFzcyAzIENv
# ZGUgU2lnbmluZyAyMDA0IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEAvrzuvH7vg+vgN0/7AxA4vgjSjH2d+pJ/GQzCa+5CUoze0xxIEyXqwWN6+VFl
# 7tOqO/XwlJwr+/Jm1CTa9/Wfbhk5NrzQo3YIHiInJGw4kSfihEmuG4qh/SWCLBAw
# 6HGrKOh3SlHx7M348FTUb8DjbQqP2dhkjWOyLU4n9oUO/m3jKZnihUd8LYZ/6FeP
# rWfCMzKREyD8qSMUmm3ChEt2aATVcSxdIfqIDSb9Hy2RK+cBVU3ybTUogt/Za1y2
# 1tmqgf1fzYO6Y53QIvypO0Jpso46tby0ng9exOosgoso/VMIlt21ASDR+aUY58Du
# UXA34bYFSFJIbzjqw+hse0SEuwIDAQABo4IBoDCCAZwwEgYDVR0TAQH/BAgwBgEB
# /wIBADBEBgNVHSAEPTA7MDkGC2CGSAGG+EUBBxcDMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEwMQYDVR0fBCowKDAmoCSgIoYgaHR0
# cDovL2NybC52ZXJpc2lnbi5jb20vcGNhMy5jcmwwHQYDVR0lBBYwFAYIKwYBBQUH
# AwIGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIBBjARBglghkgBhvhCAQEEBAMCAAEw
# KQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEUNsYXNzM0NBMjA0OC0xLTQzMB0GA1Ud
# DgQWBBQI9VHo+/49PWQ2fGjPW3io37nFNzCBgAYDVR0jBHkwd6FjpGEwXzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFz
# cyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5ghBwuuQd
# ENkpNLY4ynsDzLq/MA0GCSqGSIb3DQEBBQUAA4GBAK46F7hKe1X6ZFXsQKTtSUGQ
# mZyJvK8uHcp4I/kcGQ9/62i8MtmION7cP9OJtD+xgpbxpFq67S4m0958AW4ACgCk
# BpIRSAlA+RwYeWcjJOC71eFQrhv1Dt3gLoHNgKNsUk+RdVWKuiLy0upBdYgvY1V9
# HlRalVnK2TSBwF9e9nq1MIIE/zCCA+egAwIBAgIQOpr7msrFf6pX5iXFUEeZ7TAN
# BgkqhkiG9w0BAQUFADCBtDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWdu
# LCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQL
# EzJUZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAo
# YykwNDEuMCwGA1UEAxMlVmVyaVNpZ24gQ2xhc3MgMyBDb2RlIFNpZ25pbmcgMjAw
# NCBDQTAeFw0wODA5MDMwMDAwMDBaFw0wOTA5MDMyMzU5NTlaMIHCMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEPMA0GA1UEBxMGSXJ2aW5lMRcwFQYD
# VQQKFA5RdWVzdCBTb2Z0d2FyZTE+MDwGA1UECxM1RGlnaXRhbCBJRCBDbGFzcyAz
# IC0gTWljcm9zb2Z0IFNvZnR3YXJlIFZhbGlkYXRpb24gdjIxGzAZBgNVBAsUEldp
# bmRvd3MgTWFuYWdlbWVudDEXMBUGA1UEAxQOUXVlc3QgU29mdHdhcmUwgZ8wDQYJ
# KoZIhvcNAQEBBQADgY0AMIGJAoGBAOzhy2kROZ+RmIQSWeVG7GGYZYCkUe6H7Qxa
# SFvyUnbaft73CkQodnLYx5feVpazJFNQJlzUmcStao12VN8/SGRfa0trG61PwcP9
# cdpA3OYMJUw3StEOkfwxHkG1r86AS0mLCPWHTzxlv+aVs6/k47p0JSPGXxFs6vwn
# kyrXxfibAgMBAAGjggF/MIIBezAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIHgDBA
# BgNVHR8EOTA3MDWgM6Axhi9odHRwOi8vQ1NDMy0yMDA0LWNybC52ZXJpc2lnbi5j
# b20vQ1NDMy0yMDA0LmNybDBEBgNVHSAEPTA7MDkGC2CGSAGG+EUBBxcDMCowKAYI
# KwYBBQUHAgEWHGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwdQYIKwYBBQUHAQEEaTBnMCQGCCsGAQUFBzABhhhodHRwOi8v
# b2NzcC52ZXJpc2lnbi5jb20wPwYIKwYBBQUHMAKGM2h0dHA6Ly9DU0MzLTIwMDQt
# YWlhLnZlcmlzaWduLmNvbS9DU0MzLTIwMDQtYWlhLmNlcjAfBgNVHSMEGDAWgBQI
# 9VHo+/49PWQ2fGjPW3io37nFNzARBglghkgBhvhCAQEEBAMCBBAwFgYKKwYBBAGC
# NwIBGwQIMAYBAQABAf8wDQYJKoZIhvcNAQEFBQADggEBAAKkBGa0vkqJpeJonGIr
# hCN+mC+cBCNpXuMe/nlxz6EiAfqipmX9AmIk5CuFtpHggLQTPqi9yHW7KdRwJil1
# RUefvsat6zkDcKxIwq2asQeVuxJethSkYeb9gjQBC1ODPWyW7K4/GIzWrdXdBzIO
# ynlt/cGb+DP4PlpkZoi4YJn10hvxz3vQyfiv9LB6nyDXygsnWJLN4oIXj+PLyzYt
# FiEQpyO4NfvFHr8WUexVfr+S2pQflSh+RvYNbhrticMXNvUKQqnFpvAySIMyOeM1
# zd3QjdKTtr35tsrhiREsfmJiVpU57850Cmv/18LKL95C/upPj1NNWvNZwIjpx8zT
# sq8xggNkMIIDYAIBATCByTCBtDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlT
# aWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYD
# VQQLEzJUZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3Jw
# YSAoYykwNDEuMCwGA1UEAxMlVmVyaVNpZ24gQ2xhc3MgMyBDb2RlIFNpZ25pbmcg
# MjAwNCBDQQIQOpr7msrFf6pX5iXFUEeZ7TAJBgUrDgMCGgUAoHAwEAYKKwYBBAGC
# NwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFHT5alNjTpzjgImInxhl
# 44Xs67x7MA0GCSqGSIb3DQEBAQUABIGA5SASUw0SZpqvyLrNCToLCeo7/F6jTG1U
# rfIvIXiBOWkQ39FoFU6tPBafuwJHP7OD7Ru/SMx7hBNKEauInMKGACWslI+byqsp
# +yMgPJQ138a8LuuS1aykxyXYgTMx+TWC/Cao9kM9aRNZwjEgksw6bZFylHRbTVbN
# +h+YdrwWInqhggF+MIIBegYJKoZIhvcNAQkGMYIBazCCAWcCAQEwZzBTMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xKzApBgNVBAMTIlZlcmlT
# aWduIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0ECEDgl1/r4Ya+e9JDnJrXWWtUw
# DAYIKoZIhvcNAgUFAKBZMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZI
# hvcNAQkFMQ8XDTA4MDkxMTIxMzc0NVowHwYJKoZIhvcNAQkEMRIEEJo7RCLvvOwC
# k9kv2htRfn8wDQYJKoZIhvcNAQEBBQAEgYBtU1xVmpkVcfsHfYhpi0ItRdb+PdRq
# kfviU+JSAOnitpacWrf8GG/5vcN+/ecnwodGAnRuScv1was+oIDdyEMxyjr+3TWb
# Xr3qXCC5npIt3eJYB0tFkEWrDgTfKRJ2aLT6Gv7DvvBlwzk08VKR3AUjaQ472FRk
# isAPwWAx5ottMw==
# SIG # End signature block
