#requires -version 2.0
## HttpRest module
####################################################################################################
## Initial stages of changing HttpRest into a v2-only module
## Based on the REST api from MindTouch's Dream SDK
##
## INSTALL:
## You need mindtouch.dream.dll (mindtouch.core.dll, SgmlReaderDll.dll, log4net.dll) from the SDK
## Download DREAM from http`://sourceforge.net/project/showfiles.php?group_id=173074 
## Unpack it, and you can find these dlls in the "dist" folder.
## Make sure to put them in the folder with this script module.
##
## For documentation of Dream:  http`://wiki.developer.mindtouch.com/Dream
####################################################################################################
## Version History
## 1.0   First Release
## 1.0.1 Added Get-WebPageContent
## 1.0.2 Bug fix for Invoke-Http credential issues
## 1.1.0 First release of a PowerShell 2.0 (CTP3/Windows7) version....
####################################################################################################
## Usage:
##   function Get-Google {
##     Invoke-Http GET http`://www.google.com/search @{q=$args} | 
##       Receive-Http Xml "//h3[@class='r']/a" | Select href, InnerText 
##   }
##   #########################################################################
##   function Get-WebFile($url,$cred) {
##     Invoke-Http GET $url -auth $cred | Receive-Http File
##   }
##   #########################################################################
##   function Send-Paste {
##   PARAM($PastebinURI="http`://posh.jaykul.com/p/",[IO.FileInfo]$file)
##   PROCESS {
##     if($_){[IO.FileInfo]$file=$_}
## 
##     if($file.Exists) { 
##       $ofs="`n"
##       $result = Invoke-Http POST $PastebinURI @{
##         format="posh"           # PowerShell
##         expiry="d"              # (d)ay or (m)onth or (f)orever
##         poster=$([Security.Principal.WindowsIdentity]::GetCurrent().Name.Split("\")[-1])
##         code2="$((gc $file) -replace "http`://","http``://")" # To get past the spam filter.
##         paste="Send"
##       } -Type FORM_URLENCODED -Wait
##       $xml = $result.AsDocument().ToXml()
##       write-output $xml.SelectSingleNode("//*[@class='highlight']/*").href
##     } else { throw "File Not Found" }
##   }}
##
####################################################################################################
if(!$PSScriptRoot){ 
   Write-Debug $($MyInvocation.MyCommand | out-string)
   $PSScriptRoot=(Split-Path $MyInvocation.MyCommand.Path -Parent) 
}
#  Write-Debug "Invocation: $($MyInvocation.MyCommand.Path)"
#  Write-Debug "Invocation: $($MyInvocation.MyCommand)"
#  Write-Debug "Invocation: $($MyInvocation)"

Write-Debug "PSScriptRoot: '$PSScriptRoot'"


# This Module depends on MindTouch.Dream 
$null = [Reflection.Assembly]::LoadFrom( "$PSScriptRoot\mindtouch.dream.dll" )
# MindTouch.Dream requires: mindtouch.dream.dll, mindtouch.core.dll, SgmlReaderDll.dll, and log4net.dll)
# This Module also depends on utility functions from System.Web
$null = [Reflection.Assembly]::LoadWithPartialName("System.Web")

## Some utility functions are defined at the bottom
[uri]$global:url = ""
[System.Management.Automation.PSCredential]$global:HttpRestCredential = $null

function Get-DreamMessage($Content,$Type) {
   Write-Verbose "Content: $(if($Content){$Content.GetType()}else{"null"}) $($Content.Length) and Type: $(if($Type){$Type.GetType()}else{"null"})"
   if(!$Content) { 
      Write-Verbose "No Content"
      return [MindTouch.Dream.DreamMessage]::Ok()
   }
   if( $Content -is [System.Xml.XmlDocument]) {
      Write-Verbose "Xml Content"
      return [MindTouch.Dream.DreamMessage]::Ok( $Content )
   }
   
   if(Test-Path $Content -EA "SilentlyContinue") {
      Write-Verbose "File Content"
      return [MindTouch.Dream.DreamMessage]::FromFile((Convert-Path (Resolve-Path $Content))); 
   }
   if($Type -is [String]) {
      Write-Verbose "Specific Content: $([MindTouch.Dream.MimeType]::$Type)"
      $Type = [MindTouch.Dream.MimeType]::$Type
   }
   if($Type -is [MindTouch.Dream.DreamMessage]) {
      Write-Verbose "Specific Content: $([MindTouch.Dream.MimeType]::$Type)"
      return [MindTouch.Dream.DreamMessage]::Ok( $Type, $Content )
   } else {  
      Write-Verbose "Unspecified string content"
      return [MindTouch.Dream.DreamMessage]::Ok( $([MindTouch.Dream.MimeType]::TEXT), $Content )
   }
}

function Get-DreamPlug {
   [CmdletBinding()]
   PARAM ( $Url, [hashtable]$With )
   if($Url -is [array]) {
      Write-Verbose "URL is an array of parts"
      if($Url[0] -is [hashtable]) {
         Write-Verbose "URL is an array of hashtable parts"
         $plug = [MindTouch.Dream.Plug]::New($global:url)
         foreach($param in $url.GetEnumerator()) {
            if($param.Value) {
               $plug = $plug.At($param.Key,"=$(Encode-Twice $param.Value)")
            } else {
               $plug = $plug.At($param.Key)
            }
         }
      } 
      else 
      {
         [URI]$uri = Join-Url $global:url $url 
         $plug = [MindTouch.Dream.Plug]::New($uri)
      }
   }
   elseif($url -is [string]) 
   {
      Write-Verbose "String URL"
      trap { continue }
      [URI]$uri = $url
      if(!$uri.IsAbsoluteUri) {
         $uri = Join-Url $global:url $url
         Write-Verbose "Relative URL, appending to $($global:url) to get: $uri"
      }
      $plug = [MindTouch.Dream.Plug]::New($uri)
   } 
   else {
      Write-Verbose "No URL, using default $($global:url)"
      $plug = [MindTouch.Dream.Plug]::New($global:url)
   }
   if($with) { 
      foreach($param in $with.GetEnumerator()) {
         if($param.Value) {
            $plug = $plug.With($param.Key,$param.Value)
         }
      } 
      Write-Verbose "Added 'with' params: $plug"
   }
   return $plug
}

#CMDLET Receive-Http {
Function Receive-Http {
PARAM(
   #  [Parameter(Position=1, Mandatory=$false)]
   #  [ValidateSet("Xml", "File", "Text","Bytes")]
   #  [Alias("As")]
   $Output = "Xml" 
, 
   #  [Parameter(Position=2, Mandatory=$false)]
   [string]$Path
,
   #  [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Result")]
   #  [Alias("IO")]
   #  [MindTouch.Dream.Result``1[[MindTouch.Dream.DreamMessage]]]
   $InputObject
#,
   #  [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Response")]
   #  [MindTouch.Dream.DreamMessage]
   #  $response
) 
BEGIN {
   if($InputObject) {
      Write-Output $inputObject | Receive-Http $Output $Path 
   } # else they'd better pass it in on the pipeline ... 
}
PROCESS {
   $response = $null
   if($_ -is [MindTouch.Dream.Result``1[[MindTouch.Dream.DreamMessage]]]) {
      $response = $_.Wait()
   } elseif($_ -is [MindTouch.Dream.DreamMessage]) {
      $response = $_
   } elseif($_) {
      throw "We can only pipeline [MindTouch.Dream.DreamMessage] objects, or [MindTouch.Dream.Result`1[DreamMessage]] objects"
   }
   
   if($response) {
      Write-Debug $($response | Out-String)
      if(!$response.IsSuccessful) {
         Write-Error $($response | Out-String)
         Write-Verbose $response.AsText()
         throw "ERROR: '$($response.Status)' Response Status."
      } else {   
         switch($Output) {
            "File" {
               ## Joel's magic filename guesser ...
               if(!$Path) { 
                  [string]$fileName = ([regex]'(?i)filename=(.*)$').Match( $response.Headers["Content-Disposition"] ).Groups[1].Value
                  $Path = $fileName.trim("\/""'")
                  if(!$Path) {
                     $fileName = $response.ResponseUri.Segments[-1]
                     $Path = $fileName.trim("\/")
                     if(!([IO.FileInfo]$Path).Extension) {
                        $Path = $Path + "." + $response.ContentType.Split(";")[0].Split("/")[1]
                     }
                  }
               }
               
               $File = Get-FileName $Path
               [StreamUtil]::CopyToFile( $response.AsStream(), $response.ContentLength, $File )
               Get-ChildItem $File
            }
            "XDoc" {
               if($Path) { 
                  $response.AsDocument()[$Path]
               } else {
                  $response.AsDocument()#.ToXml()
               }
            }
            "Xml" {
               if($Path) { 
                  $response.AsDocument().ToXml().SelectNodes($Path)
               } else {
                  $response.AsDocument().ToXml()
               }
            }
            "Text" {
               if($Path) { 
                  $response.AsDocument()[$Path] | % { $_.AsText }
               } else {
                  $response.AsText()
               }
            }
            "Bytes" {
               $response.AsBytes()
            }
         }
      }
   }
}
}
## http`://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
## Nobody actually uses HEAD or OPTIONS, right?
## And nobody's even heard of TRACE or CONNECT ;) 

# CMDLET Invoke-Http {
Function Invoke-Http {
[CmdletBinding()]
PARAM( 
   [Parameter(Position=0, Mandatory=$false)]
   [ValidateSet("Post", "Get", "Put", "Delete", "Head", "Options")] ## There are other verbs, but we need a list to make sure you don't screw up
   [string]$Verb = "Get"
,
   [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
   [string]
   $Path
, 
   [Parameter(Position=2, Mandatory=$false)]
   [hashtable]$with
, 
   [Parameter(Mandatory=$false)]
   $Content
,
   [Parameter(Mandatory=$false)]
   $Type # Of Content
,
   [Parameter(ParameterSetName="UseDefaultCredentials")]
   $authenticate
, 
   [Parameter(ParameterSetName="ManualCredentials")]
   $credentials
, 
   [switch]$waitForResponse
)
PROCESS {
      $plug = Get-DreamPlug $Path $With
      Write-Verbose "Content Type: $Type"
      Write-Verbose "Content: $Content"
      ## Special Handling for FORM_URLENCODED
      if($Type -like "Form*" -and !$Content) {
         $dream = [MindTouch.Dream.DreamMessage]::Ok( $Plug.Uri )
         $Plug = [MindTouch.Dream.Plug]::New( $Plug.Uri.SchemeHostPortPath )
         Write-Verbose "RECREATED Plug: $($Plug.Uri.SchemeHostPortPath)"
      } else {
         $dream = Get-DreamMessage $Content $Type
         Write-Verbose "Created Dream with Content: $($dream.Content)"
      }
      
      if(!$plug -or !$dream) {
         throw "Can't come up with a request!"
      }
      
      Write-Verbose $("DREAM!",$dream | Out-String )
      
      if($authenticate -or $credentials){ 
         if($credentials -is [System.Management.Automation.PSCredential]) {
            Write-Verbose "AUTHENTICATING AS $($credentials.GetNetworkCredential().UserName)"
            $plug = $plug.WithCredentials($credentials.GetNetworkCredential())
         } elseif($credentials -is [System.Net.ICredentials]) {
            Write-Verbose "AUTHENTICATING AS $($credentials.GetNetworkCredential().UserName)"
            $plug = $plug.WithCredentials($credentials.GetNetworkCredential())
         } else {
            if($credentials) {
               Write-Error "Credential must be a PSCredential or a System.Net.ICredentials"
            }
            $null = Get-HttpCredential  # Make sure they have global credentials
            Write-Verbose "AUTHENTICATING AS $($global:HttpRestCredential.UserName)"
            $plug = $plug.WithCredentials($global:HttpRestCredential.GetNetworkCredential())
         }
      }
      
      Write-Verbose $plug.Uri
      
      ## DEBUG:
      Write-Debug "URI: $($Plug.Uri)"
      Write-Debug "Verb: $($Verb.ToUpper())"
      Write-Debug $($dream | Out-String)
      
      $result = $plug.InvokeAsync( $Verb.ToUpper(),  $dream )
      
      Write-Debug $($result | Out-String)
      #  if($DebugPreference -eq "Continue") {
      #     Write-Debug $($result.Wait() | Out-String)
      #  }
      
      if($waitForResponse) { 
         $result = $result.Wait() 
      }
      
      write-output $result
   
      trap [MindTouch.Dream.DreamResponseException] {
         Write-Error @"
TRAPPED DreamResponseException
      
$($_.Exception.Response | Out-String)

$($_.Exception.Response.Headers | Out-String)
"@
         break;
      }
}
}


function Get-WebPageContent {
[CmdletBinding()]
param( 
   [Parameter(Position=0,Mandatory=$true)]
   [string]$url
,
   [Parameter(Position=1,Mandatory=$false)]
   [string]$xpath=""
,
   [Parameter(Position=2,Mandatory=$false)]
   [hashtable]$with=@{}
,
   [Parameter(Mandatory=$false)]
   [switch]$AsXml 
,
   [Parameter(Mandatory=$false)]
   [switch]$Authenticate
)
BEGIN { $out = "Text"; if($AsXml) { $out="Xml" } }
PROCESS {
   invoke-http get $url $with -Authenticate:$Authenticate | receive-http $out $xpath
}
}

new-alias gwpc Get-WebPageContent -EA "SilentlyContinue"
new-alias http Invoke-Http        -EA "SilentlyContinue"
new-alias rcv  Receive-Http       -EA "SilentlyContinue"


# function Get-Http { return Invoke-Http "GET" @args }
# function New-Http { return Invoke-Http "PUT" @args }
# function Update-Http { return Invoke-Http "POST" @args }
# function Remove-Http { return Invoke-Http "DELETE" @args }
# new-alias Set-Http Update-Http
# new-alias Put-Http New-Http 
# new-alias Post-Http Update-Http
# new-alias Delete-Http Remove-Http

function Set-HttpDefaultUrl {
PARAM ([uri]$baseUri=$(Read-Host "Please enter the base Uri for your RESTful web-service"))
   $global:url = $baseUri 
}

function Set-HttpCredential {
   param($Credential=$(Get-CredentialBetter -Title   "Http Authentication Request - $($global:url.Host)" `
                                      -Message "Your login for $($global:url.Host)" `
                                      -Domain  $($global:url.Host)) )
   if($Credential -is [System.Management.Automation.PSCredential]) {
      $global:HttpRestCredential = $Credential
   } elseif($Credential -is [System.Net.NetworkCredential]) {
      $global:HttpRestCredential = new-object System.Management.Automation.PSCredential $Credential.UserName, $(ConvertTo-SecureString $credential.Password)
   }
}

function Get-HttpCredential {
   if(!$global:url) { Set-HttpDefaultUrl }
   if(!$global:HttpRestCredential) { Set-HttpCredential }
   if(!$Secure) {
      return $global:HttpRestCredential.GetNetworkCredential();
   } else {
      return $global:HttpRestCredential
   }
}

# function Authenticate-Http {
# PARAM($URL=@("users","authenticate"), $Credential = $(Get-HttpCredential))
#   $plug = [MindTouch.Dream.Plug]::New( $global:url )
#   $null = $plug.At("users", "authenticate").WithCredentials( $auth.UserName, $auth.Password ).Get()
# }


function ConvertTo-UrlDoubleEncode {
   param([string]$text)
   return [System.Web.HttpUtility]::UrlEncode( [System.Web.HttpUtility]::UrlEncode( $text ) )
}
New-Alias Encode-Twice ConvertTo-UrlDoubleEncode

function Join-Url ( [uri]$baseUri=$global:url ) {
   $ofs="/";$BaseUrl = ""
   if($BaseUri -and $baseUri.AbsoluteUri) {
      $BaseUrl = "$($baseUri.AbsoluteUri.Trim('/'))/"
   }
   return [URI]"$BaseUrl$([string]::join("/",@($args)).TrimStart('/'))"
}

function ConvertTo-SecureString {
Param([string]$input)
   $result = new-object System.Security.SecureString

   foreach($c in $input.ToCharArray()) {
      $result.AppendChar($c)
   }
   $result.MakeReadOnly()
   return $result
}

## Unit-Test Get-FileName  ## Should return TRUE
##   (Get-FileName C:\Windows\System32\Notepad.exe)               -eq "C:\Windows\System32\Notepad.exe"   -and
##   (Get-FileName C:\Windows\Notepad.exe C:\Windows\System32\)   -eq "C:\Windows\System32\Notepad.exe"   -and
##   (Get-FileName WaitFor.exe C:\Windows\System32\WaitForIt.exe) -eq "C:\Windows\System32\WaitForIt.exe" -and
##   (Get-FileName -Path C:\Windows\System32\WaitForIt.exe)       -eq "C:\Windows\System32\WaitForIt.exe"      
function Get-FileName {
   param($fileName=$([IO.Path]::GetRandomFileName()), $path)
   $fileName = $fileName.trim("\/""'")
   ## if the $Path has a file name, and it's folder exists:
   if($Path -and !(Test-Path $Path -Type Container) -and (Test-Path (Split-Path $path) -Type Container)) {
      $path
   ## if the $Path is just a folder (and it exists)
   } elseif($Path -and (Test-Path $path -Type Container)) {
      $fileName = Split-Path $fileName -leaf
      Join-Path $path $fileName
   ## If there's no valid $Path, and the $FileName has a folder...
   } elseif((Split-Path $fileName) -and (Test-Path (Split-Path $fileName))) {
      $fileName
   } else {
      Join-Path (Get-Location -PSProvider "FileSystem") (Split-Path $fileName -Leaf)
   }
}

function Get-UtcTime {
   Param($Format="yyyyMMddhhmmss")
   [DateTime]::Now.ToUniversalTime().ToString($Format)
}

## Get-CredentialBetter 
## An improvement over the default cmdlet which has no options ...
###################################################################################################
## History
## v 1.2 Refactor ShellIds key out to a variable, and wrap lines a bit
## v 1.1 Add -Console switch and set registry values accordingly (ouch)
## v 1.0 Add Title, Message, Domain, and UserName options to the Get-Credential cmdlet
###################################################################################################
function Get-CredentialBetter{ 
PARAM([string]$UserName, [string]$Title, [string]$Message, [string]$Domain, [switch]$Console)
   $ShellIdKey = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds"
   ## Carefully EA=SilentlyContinue because by default it's MISSING, not $False
   $cp = (Get-ItemProperty $ShellIdKey ConsolePrompting -ea "SilentlyContinue")
   ## Compare to $True, because by default it's $null ...
   $cp = $cp.ConsolePrompting -eq $True

   if($Console -and !$cp) {
      Set-ItemProperty $ShellIdKey ConsolePrompting $True
   } elseif(!$Console -and $Console.IsPresent -and $cp) {
      Set-ItemProperty $ShellIdKey ConsolePrompting $False
   }

   ## Now call the Host.UI method ... if they don't have one, we'll die, yay.
   $Host.UI.PromptForCredential($Title,$Message,$UserName,$Domain,"Generic","Default")

   ## BoyScouts: Leave everything better than you found it (I'm tempted to leave it = True)
   Set-ItemProperty $ShellIdKey ConsolePrompting $cp -ea "SilentlyContinue"
}

Export-ModuleMember -Function * -Alias *
# Export-ModuleMember Invoke-Http, Receive-Http, Set-HttpCredential, Set-HttpDefaultUrl
# SIG # Begin signature block
# MIILCQYJKoZIhvcNAQcCoIIK+jCCCvYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoniyyA7pKrlhV2+dvfWyjfsv
# RvGgggbgMIIG3DCCBMSgAwIBAgIJALPpqDj9wp7xMA0GCSqGSIb3DQEBBQUAMIHj
# MQswCQYDVQQGEwJVUzERMA8GA1UECBMITmV3IFlvcmsxEjAQBgNVBAcTCVJvY2hl
# c3RlcjEhMB8GA1UEChMYaHR0cDovL0h1ZGRsZWRNYXNzZXMub3JnMSgwJgYDVQQL
# Ex9TY3JpcHRpbmcgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MTcwNQYDVQQDEy5odHRw
# Oi8vSHVkZGxlZE1hc3Nlcy5vcmcgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MScwJQYJ
# KoZIhvcNAQkBFhhKYXlrdWxASHVkZGxlZE1hc3Nlcy5vcmcwHhcNMDkwMzE1MTkx
# OTE5WhcNMTAwMzE1MTkxOTE5WjCBqzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE5l
# dyBZb3JrMRIwEAYDVQQHEwlSb2NoZXN0ZXIxITAfBgNVBAoTGGh0dHA6Ly9IdWRk
# bGVkTWFzc2VzLm9yZzESMBAGA1UECxMJU2NyaXB0aW5nMRUwEwYDVQQDEwxKb2Vs
# IEJlbm5ldHQxJzAlBgkqhkiG9w0BCQEWGEpheWt1bEBIdWRkbGVkTWFzc2VzLm9y
# ZzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAPfqxOG9TQN+qZjZ6KfM
# +zBK0YpjeyPL/cFgiGBhiIdYWTBtkbZydFr3IiERKRsUJ0/SKFbhf0C3Bvd/neTJ
# qiZjH4D6xkrfdLlWMmmSXXqjSt48jZp+zfCAIaF8K84e9//7lMicdVFE6VcgoATZ
# /eMKQky4JvphJpzDHYPLxLJQrKd0pjDDwspjdX5RedWkzeZBG7VfBnebLWUzgnMX
# IxRQKfFCMryQDP8weceOnJjfJEf2FYmdpsEg5EKKKbuHsQCMVTxfteKdPvh1oh05
# 1GWyPsvEPh4auJUT8pAVvrdxq+/O9KW/UV01UxjRYM1vdklNw8g7mkJTrrHjSjl7
# tuugCnJjt5kN6v/OaUtRRMR68O85bSTVGOxJGCHUKlyuuTx9tnfIgy4siFYX1Ve8
# xwaAdN3haTon3UkWzncHOq3reCIVF0luwRZu7u+TnOAnz2BRlt+rcT0O73GN20Fx
# gyN2f5VGBbw1KuS7T8XZ0TFCspUdgwAcmTGuEVJKGhVcGAvNlLx+KPc5dba4qEfs
# VZ0MssC2rALC1z61qWuucb5psHYhuD2tw1SrztywuxihIirZD+1+yKE4LsjkM1zG
# fQwDO/DQJwkdByjfB2I64p6mk36OlZAFxVfRBpXSCzdzbgKpuPsbtjkb5lGvKjE1
# JFVls1SHLJ9q80jHz6yW7juBAgMBAAGjgcgwgcUwHQYDVR0OBBYEFO0wLZyg+qGH
# Z4WO8ucEGNIdU1T9MB8GA1UdIwQYMBaAFN2N42ZweJLF1mz0j70TMxePMcUHMAkG
# A1UdEwQCMAAwEQYJYIZIAYb4QgEBBAQDAgTwMCoGA1UdJQEB/wQgMB4GCCsGAQUF
# BwMBBggrBgEFBQcDAgYIKwYBBQUHAwMwCwYDVR0PBAQDAgTwMCwGCWCGSAGG+EIB
# DQQfFh1PcGVuU1NMIEdlbmVyYXRlZCBDZXJ0aWZpY2F0ZTANBgkqhkiG9w0BAQUF
# AAOCAgEAmKihxd6KYamLG0YLvs/unUTVJ+NW3jZP16R28PpmidY/kaBFOPhYyMl2
# bBGQABe7LA5rpHFAs0F56gYETNoFk0qREVvaoz9u18VfLb0Uwqtnq0P68L4c7p2q
# V3nKmWjeI6H7BAyFuogxmMH5TGDfiqrrVSuh1LtPbkV2Wtto0SAxP0Ndyts2J8Ha
# vu/2rt0Ic5AkyD+RblFPtzkCC/MLVwSNAiDSKGRPRrLaiGxntEzR59GRyf2vwhGg
# oAXUqcJ/CVeHCP6qdSTM39Ut3RmMZHXz5qY8bvLgNYL6MtcJAx+EeUhW497alzm1
# jInXdbikIh0d/peTSDyLbjS8CPFFtS6Z56TDGMf+ouTpEA16otcWIPA8Zfjq+7n7
# iBHjeuy7ONoJ2VDNgqn9B+ft8UWRwnJbyB85T83OAGf4vyhCPz3Kg8kWxY30Bhnp
# Fayc6zQKCpn5o5T0/a0BBHwAyMfr7Lhav+61GpzzG1KfAw58N2GV8KCPKNEd3Zdz
# y07aJadroVkW5R+35mSafKRJp5pz20GDRwZQllqGH1Y/UJFEiI0Bme9ecbl2vzNp
# JjHyl/jLVzNVrBI5Zwb0lCLsykApgNY0yrwEqaiqwcxq5nkXFDhDPQvbdulihSo0
# u33fJreCm2fFyGbTuvR61goSksAvLQhvijLAzcKqWKG+laOtYpAxggOTMIIDjwIB
# ATCB8TCB4zELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE5ldyBZb3JrMRIwEAYDVQQH
# EwlSb2NoZXN0ZXIxITAfBgNVBAoTGGh0dHA6Ly9IdWRkbGVkTWFzc2VzLm9yZzEo
# MCYGA1UECxMfU2NyaXB0aW5nIENlcnRpZmljYXRlIEF1dGhvcml0eTE3MDUGA1UE
# AxMuaHR0cDovL0h1ZGRsZWRNYXNzZXMub3JnIENlcnRpZmljYXRlIEF1dGhvcml0
# eTEnMCUGCSqGSIb3DQEJARYYSmF5a3VsQEh1ZGRsZWRNYXNzZXMub3JnAgkAs+mo
# OP3CnvEwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwIwYJKoZIhvcNAQkEMRYEFPtIbR2Ib33ue+orAhek3JvLdPn7MA0GCSqG
# SIb3DQEBAQUABIICAJxGyC9H8QzR7pAW2U6p4ZwEN6ACNwdOg6etL8oKm6kHh/pr
# wVSKveDeErRQJ2I/ZU5sW147870fsUpQIoz7HmSd3iYWw9Ew7/pan+iXFtEJkWfZ
# QVAa1BAGsUFUQ0F+BoLD2EoRIHOBjt2qiJIiVUoHGTOo26DYSeCBeHXpSXCNcK6c
# R79WQ8QM6d4lsnrR01GOZI5XAUQPTVSMnQbkoQJCE/jFcrHmoLSwFO2LNGhFGhyV
# NO9OAGBD3WKCIoBpZfJ2xZS8byDUmk47h4NCG33gCwLsm4P138CZ7l0h+5LxvXOx
# 8BjcmmdwjIKny18EHb6X7qsfL6aYBwiXFzKdW1mc6l1oEtYpyeCbUMZDQA31nZ7Y
# Y3hRWP9SDxzdArVGH5uxo2RKgXY4Yqxq+rWRY9W4WYlWGbfe2SVnBBLnkeAyeLtR
# 2L59g+BuTqlCRuT1rKabW3AgquJHG9kuO1RsDefNlTjda/+NgwIciQONQDbfFHs+
# 23G3pEFGSmdgQtvZXlR+02xgzogQwLuSzDUzyVVe0ow1nQ26vTmMBlXVN+YlOoj/
# ZENATe2mDDh6G4zoWepr/GTeMH61d1Fwnq4VDd3O6m/jogNTUz5XQzqUvsABIccr
# mC3oC7NgymO55FZDX/ecU/Hkb8e55U3roHFsyWz+XZaonkFmgPVMIQGfG5lH
# SIG # End signature block

