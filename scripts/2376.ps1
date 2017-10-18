#requires -Version 2.0
##requires -Module HttpRest -Version 1.2
# http://poshcode.org/1262
Set-StrictMode -Version 2.0
$null = [Reflection.Assembly]::LoadWithPartialName('System.Web')
$safeChars = [char[]]'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~'

function Get-OAuthBase {
#.Synopsis
#  Get the basic OAuth Authorization values
#.Parameter ConsumerKey
#  The OAuth Consumer Key
#.Parameter AccessToken
#  The OAuth Access token
#.Parameter AccessVerifier
#  The OAuth Access verifier from the user's interaction with the web site ...
#.ReturnValue
#  A HashTable containing the key-value pairs needed for further requests, including the 
#  oauth_consumer_key, oauth_signature_method, oauth_timestamp, oauth_nonce, oauth_version, and optionally, the oauth_token.
PARAM( 
   [Parameter(Mandatory=$true)]$ConsumerKey
,  [Parameter(Mandatory=$false)]$AccessToken 
,  [Parameter(Mandatory=$false)]$AccessVerifier
,  [Parameter(Mandatory=$false)]
   [ValidateSet("HMAC-SHA1", "PLAINTEXT")]
   [String]
   $SignatureMethod = "HMAC-SHA1"
)
END {
   @{ 
      oauth_consumer_key      = Format-OAuth $ConsumerKey
      oauth_signature_method  = $SignatureMethod # The signature method the Consumer used to sign the request
      oauth_timestamp         = [int]((Get-Date).ToUniversalTime() - (Get-Date 1/1/1970)).TotalSeconds
      oauth_nonce             = [guid]::NewGuid().GUID -replace '-'
      oauth_version           = '1.0' # OPTIONAL: If present, value MUST be 1.0
   } + $(if($AccessToken){ @{oauth_token = $AccessToken } } else { @{} }
   ) + $(if($AccessVerifier){ @{oauth_verifier = $AccessVerifier } } else { @{} }) # $FFAccessToken.oauth_token
}}

function Format-OAuth {
#.Synopsis 
#  UrlEncode, but with upper-case hex
#.Parameter value
#  The text to encode
PARAM([Parameter(ValueFromPipeline=$true)][string]$value)
PROCESS {
   $result = New-Object System.Text.StringBuilder
   foreach($c in $value.ToCharArray()){
      if($safeChars -notcontains $c) {
         $null = $result.Append( ('%{0:X2}' -f [int]$c) )
      } else {
         $null = $result.Append($c)
      }
   }
   write-output $result.ToString()
}}

function ConvertTo-Hashtable {
#.Synopsis
#  Convert a query string into a hashtable
#.Parameter string
#  The query string to convert
#.Parameter PairSeparator
#  The string separating each set of key=value pairs
#.Parameter KeyValueSeparator
#  The string separating the keys from the values
#.ReturnValue
#  The hashtable created from reading the query string
PARAM(
   [Parameter(ValueFromPipeline=$true, Position=0, Mandatory=$true)]
   [String]
   $string
,
   [Parameter(Position=1)]
   [String]
   $PairSeparator = '&'
,  
   [Parameter(Position=2)]
   [String]
   $KeyValueSeparator = '='
)
PROCESS {
   $result = @{}
   foreach($w in $string.split($pairSeparator) ) {
      $k,$v = $w.split($KeyValueSeparator,2)
      $result.Add($k,$v)
   }
   write-output $result
}
}

function ConvertFrom-Hashtable {
#.Synopsis
#  Convert a hashtable into a query string
#.Description
#  Converts a hashtable into a query string by joining the keys to the values, and then joining all the pairs together
#.Parameter values
#  The hashtable to convert
#.Parameter PairSeparator
#  The string used to concatenate the sets of key=value pairs, defaults to "&"
#.Parameter KeyValueSeparator
#  The string used to concatenate the keys to the values, defaults to "="
#.ReturnValue
#  The query string created by joining keys to values and then joining them all together into a single string
PARAM(
   [Parameter(ValueFromPipeline=$true, Position=0, Mandatory=$true)]
   [Hashtable]
   $Values
,
   [Parameter(Position=1)]
   [String]
   $pairSeparator = '&'
,  
   [Parameter(Position=2)]
   [String]
   $KeyValueSeparator = '='
,
   [string[]]$Sort
)
PROCESS {
   [string]::join($pairSeparator, @(
      if($Sort) {
         foreach( $kv in $Values.GetEnumerator() | Sort $Sort) {
            if($kv.Name) {
               '{0}{1}{2}' -f $kv.Name, $KeyValueSeparator, $kv.Value
            }
         }
      } else {
         foreach( $kv in $Values.GetEnumerator()) {
            if($kv.Name) {
               '{0}{1}{2}' -f $kv.Name, $KeyValueSeparator, $kv.Value
            }
         }
      }
   ))
}}

function ConvertTo-OAuthSignatureBase {
#.Synopsis
#  An internal function to build up the string needed for the OAuth Signature
PARAM(
   [Parameter(Mandatory=$true)]
   [Uri]
   $Uri
,
   [Parameter(Mandatory=$false)]
   [hashtable]
   $Parameters =@{}
,
   [Parameter(Mandatory=$false)]
   [ValidateSet("POST", "GET", "PUT", "DELETE", "HEAD", "OPTIONS")]
   [string]
   $Verb = "GET"
#  ,
   #  [System.Management.Automation.PSCredential]
   #  $Credential
)
BEGIN {
   trap { continue }
   if(!$Uri.IsAbsoluteUri) {
      $Uri= Join-Url $global:url $Uri
      Write-Verbose "Relative URL, appending to $($global:url) to get: $Uri"
   }
}
END {
      $normalizedUrl = ("{0}://{1}" -f $Uri.Scheme, $Uri.Host).ToLower()
      if (!(($Uri.Scheme -eq "http" -and $Uri.Port -eq 80) -or ($Uri.Scheme -eq "https" -and $Uri.Port -eq 443)))
      {
          $normalizedUrl += ":" + $Uri.Port
      }
      
      $normalizedUrl += $Uri.AbsolutePath
      write-output $normalizedUrl

      if($Uri.Query) { 
         $Parameters += $(ConvertTo-Hashtable $Uri.Query.trim("?"))
      }
      $normalizedRequestParameters = Format-OAuth (ConvertFrom-Hashtable $Parameters -Sort "Name","Value")
      
      ## DEBUG  Write-Host $normalizedRequestParameters -fore yellow
      write-output $normalizedRequestParameters
      
      $result = New-Object System.Text.StringBuilder
      $null = $result.AppendFormat("{0}&", $verb.ToUpper() )
      $null = $result.AppendFormat("{0}&", $(Format-OAuth $normalizedUrl) )
      $null = $result.AppendFormat("{0}", $normalizedRequestParameters)

      ## DEBUG  Write-Host $result.ToString() -fore cyan
      write-output $result.ToString();
   }
}

function Get-OAuthSignature {
#.Synopsis
#  An internal function to calculate the OAuth Signature using the HMAC-SHA1 algorithm
#.Parameter Verb
#  The HTTP verb which will be invoked is the first part of the OAuth Signature string (defaults to GET)
#.Parameter Uri
#  The URI which will be queried is the second part of the OAuth Signature string
#.Parameter Parameters
#  All of the parameters which will be passed (regardless of how they will be passed) in hashtable format. The OAuth Base Authorization parameters are not included here, they will be set by this function
#.Parameter ConsumerKey
#  The OAuth Consumer Key (a key specific to the application requesting access)
#.Parameter ConsumerSecret
#  The OAuth Consumer Secret (the secret part of the application's consumer key shouldn't be given to end users)
#.Parameter AccessToken
#  The OAuth Access Token (if you're already authenticated)
#.Parameter ConsumerSecret
#  The OAuth Access Secret (the secret part of the access token, if you're already authenticated)
PARAM( 
   [Parameter(Mandatory=$true)]
   [Uri]
   $Uri
,
   [Parameter(Mandatory=$false)]
   [hashtable]
   $Parameters =@{}
,
   [Parameter(Mandatory=$true)]
   [string]
   $ConsumerKey = "key"
, 
   [Parameter(Mandatory=$true)]
   [string]
   $ConsumerSecret = "secret"
, 
   [Parameter(Mandatory=$false)]
   [string]
   $AccessToken = ""
, 
   [Parameter(Mandatory=$false)]
   [string]
   $AccessSecret = ""
, 
   [Parameter(Mandatory=$false)]
   [string]
   $AccessVerifier = ""
, 
   [Parameter(Mandatory=$false)]
   [ValidateSet("POST", "GET", "PUT", "DELETE", "HEAD", "OPTIONS")]
   [string]
   $Verb = "GET"
,
   [ValidateSet("HMAC-SHA1", "PLAINTEXT")]
   [String]
   $SignatureMethod = "HMAC-SHA1"
#  ,
   #  [System.Management.Automation.PSCredential]
   #  $Credential
)
END {
   @($Parameters.Keys) | % {
      $Parameters.$_ = @($Parameters.$_) | %{ Format-OAuth $_ }
   }

   $Parameters += Get-OAuthBase $ConsumerKey $AccessToken $AccessVerifier -SignatureMethod $SignatureMethod

   $url, $query, $sigbase = ConvertTo-OAuthSignatureBase -Uri $Uri -Parameters $Parameters -Verb $Verb 
   Write-Verbose ([System.Web.HttpUtility]::URLDecode( $sigbase ) -split "&" -join "`n")

   Write-Output $url, $Parameters
   if($SignatureMethod -eq "HMAC-SHA1") {
      $sha = new-object System.Security.Cryptography.HMACSHA1
      $sha.Key =  [System.Text.Encoding]::Ascii.GetBytes( ('{0}&{1}' -f $(Format-OAuth $ConsumerSecret),$(Format-OAuth $AccessSecret)) )
      Write-Output $([Convert]::ToBase64String( $sha.ComputeHash( [System.Text.Encoding]::Ascii.GetBytes( $sigbase ) ) ))
   } else {
      Write-Output ('{0}&{1}' -f $(Format-OAuth $ConsumerSecret),$(Format-OAuth $AccessSecret)) 
   }
}}

function Invoke-OAuthHttp {
#.Synopsis
#  The primary OAuth function
#.Parameter Uri
#  The URI which will be invoked against
#.Parameter Parameters
#  All of the additional parameters which will be passed (regardless of how they will be passed) in hashtable format. Obviously the OAuth Base access parameters are not included here, they will be set by this function
#.Parameter ConsumerKey
#  The OAuth Consumer Key (a key specific to the application requesting access)
#.Parameter ConsumerSecret
#  The OAuth Consumer Secret (the secret part of the application's consumer key shouldn't be given to end users)
#.Parameter AccessToken
#  The OAuth Access Token (if you're already authenticated)
#.Parameter ConsumerSecret
#  The OAuth Access Secret (the secret part of the access token, if you're already authenticated)
#.Parameter Verb
#  The HTTP verb which will be invoked (defaults to GET)
[CmdletBinding()]
PARAM(
   [Parameter(Mandatory=$true)]
   [Uri]
   $Uri
,
   [Parameter(Mandatory=$false)]
   [HashTable]
   $Parameters =@{}
,
   [Parameter(Mandatory=$true)]
   [string]
   $ConsumerKey = "key"
, 
   [Parameter(Mandatory=$true)]
   [string]
   $ConsumerSecret = "secret"
, 
   [Parameter(Mandatory=$false)]
   [string]
   $AccessToken = ""
, 
   [Parameter(Mandatory=$false)]
   [string]
   $AccessSecret = ""
,
   [Parameter(Mandatory=$false)]
   [string]
   $AccessVerifier = ""
, 
   [Parameter(Mandatory=$false)]
   [ValidateSet("POST", "GET", "PUT", "DELETE", "HEAD", "OPTIONS")]
   [string]
   $Verb = "GET"
,
   [ValidateSet("HMAC-SHA1", "PLAINTEXT")]
   [String]
   $SignatureMethod = "HMAC-SHA1"
, 
   [ValidateSet("Xml", "File", "Text","Bytes")]
   [Alias("As")]
   $Output = "Xml"
,
   [AllowEmptyString()]
   [string]$Path
)
END {
   $parameters.format = "xml"
   

   if($AccessToken -and $AccessSecret) {
      $script:url, $script:Headers, $script:sig = Get-OAuthSignature -Uri $Uri -Parameters $Parameters `
                                                -ConsumerKey    $ConsumerKey    `
                                                -ConsumerSecret $ConsumerSecret `
                                                -AccessToken    $AccessToken    `
                                                -AccessSecret   $AccessSecret   `
                                                -AccessVerifier $AccessVerifier `
                                                -Verb $Verb.ToUpper()           `
                                                -SignatureMethod $SignatureMethod
   } else {
      $script:url, $script:Headers, $script:sig = Get-OAuthSignature -Uri $Uri -Parameters $Parameters `
                                                -ConsumerKey    $ConsumerKey    `
                                                -ConsumerSecret $ConsumerSecret `
                                                -Verb $Verb.ToUpper()           `
                                                -SignatureMethod $SignatureMethod
   }
   
   $Headers += @{ oauth_signature = Format-OAuth $sig }
   $Parameters.Keys | %{ $Headers.Remove($_) }
   $WithHeader = @{ Authorization="OAuth {0}`"" -f $(ConvertFrom-Hashtable $Headers "`", " "=`"") }

   Write-Verbose $( $WithHeader | fl | Out-String )
   
   switch($Verb) {
      "POST" {
         $plug = Get-DreamPlug $Uri.AbsoluteUri -Headers $WithHeader
         $global:debugplug = $plug
         $script:result = Invoke-Http "POST" -Plug $plug -Content ([HashTable]$Parameters) | Receive-Http $Output -Path $Path
      }
      "GET" {
         $plug = Get-DreamPlug $Uri.AbsoluteUri -Headers $WithHeader -With $Parameters
         $global:debugplug = $plug
         $script:result = Invoke-Http "GET" -Plug $plug | Receive-Http $Output -Path $Path
      }
   }
      
   ## Freakydeaky magic pulls an access hashtable out of it's hat
   if(!$AccessToken -and $result -is [System.Xml.XmlDocument] -and $result.SelectNodes("html") -and $result.SelectNodes("html") -match "oauth_token_secret") {
      $result.html | ConvertTo-Hashtable
   } elseif($result -is [System.Xml.XmlDocument]){
      $result.SelectSingleNode("//*")
   } else {
      $result
   }
}
}

# http`://oauth.net/core/1.0#auth_step3
#
# A good place to practice: http`://term.ie/oauth/example/
#
# The reason I started playing:  http`://friendfeed.com/api/documentation
#                                http`://friendfeed.com/api/applications/6a3c26fe1af047bb9553b3098bee5867
#
# The docs for Yammer were also involved:  https://www.yammer.com/api_doc.html
#
# One other resource I found helpful (I had to make a few enhancements to HttpRest):
# http`://blog.developer.mindtouch.com/2009/08/05/async-io-dream-vs-parallel-extensions/
# And thanks to http`://oauth.googlecode.com/svn/code/csharp/
# And thanks to http`://oauth.googlecode.com/svn/code/python/oauth/







####################################################################################################
### This is *MY* application stuff
$global:PoshOAuthToken = @{ 
   oauth_consumer_key    = # You must put your oauth key here
   oauth_consumer_secret = # You must put your oauth secret here
}
$global:OAuthUris = @{
   AccessToken  = "https://www.yammer.com/oauth/access_token"
   RequestToken = "https://www.yammer.com/oauth/request_token"
   Authorize    = "https://www.yammer.com/oauth/access_token"
}

function Get-OAuthAccessToken {
[CmdletBinding()]
param()
#.Synopsis
#  OAuth Web Browser Authentication
   if(!(Test-Path Variable:Global:OAuthAccessToken) -or !$global:OAuthAccessToken) {
   
      $RequestToken = Invoke-OAuthHttp                            `
        -Uri             $OAuthUris.RequestToken                  `
        -ConsumerKey     $PoshOAuthToken.oauth_consumer_key       `
        -ConsumerSecret  $PoshOAuthToken.oauth_consumer_secret    `
        -Verb "POST" -SignatureMethod 'HMAC-SHA1'
   
      if(!$RequestToken) { return }
      
      $Global:DebugToken = $RequestToken
      Write-Warning "Starting browser for interactive authorization"
      $AuthURL = ("https://www.yammer.com/oauth/authorize?oauth_token={0}" -f $RequestToken.oauth_token)
      Start $AuthURL
      
      $AccessVerifier = Read-Host "Please enter the token from the web site: $AuthURL"

      $global:OAuthAccessToken = Invoke-OAuthHttp                           `
        -Uri             $OAuthUris.AccessToken                   `
        -ConsumerKey     $PoshOAuthToken.oauth_consumer_key       `
        -ConsumerSecret  $PoshOAuthToken.oauth_consumer_secret    `
        -AccessToken     $RequestToken.oauth_token            `
        -AccessSecret    $RequestToken.oauth_token_secret     `
        -AccessVerifier  $AccessVerifier                          `
        -Verb "POST"
   }
   return $global:OAuthAccessToken
}


function Invoke-OAuthorized {
[CmdletBinding()]
PARAM(
   [Parameter(Mandatory=$true)]
   [Uri]
   $Uri
,
   [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
   [hashtable]
   $Parameters =@{}
,
   [Parameter(Mandatory=$false)]
   [IO.FileInfo[]]
   $File
,
   [Parameter(Mandatory=$false)]
   [ValidateSet("POST", "GET", "PUT", "DELETE", "HEAD", "OPTIONS")]
   [string]
   $Verb = "GET"
, 
   [ValidateSet("Xml", "File", "Text","Bytes")]
   [Alias("As")]
   $Output = "Xml"
,
   [AllowEmptyString()]
   [string]$Path
)
BEGIN {
   if(!(Test-Path Variable:Global:OAuthAccessToken) -or !$global:OAuthAccessToken) {
      Write-Warning "Must fetch new Access Token"
      $Global:OAuthAccessToken = Get-OAuthAccessToken
   }
}
PROCESS {
   Write-Verbose "Fetching URI: $Uri"
   Invoke-OAuthHttp -Parameters $Parameters -Uri $Uri                            `
                    -ConsumerKey    $Global:PoshOAuthToken.oauth_consumer_key    `
                    -ConsumerSecret $Global:PoshOAuthToken.oauth_consumer_secret `
                    -AccessToken    $Global:OAuthAccessToken.oauth_token         `
                    -AccessSecret   $Global:OAuthAccessToken.oauth_token_secret  `
                    -Verb $Verb -Output $Output -Path $Path
}}


function Get-AccessTokenForIAA {
#.Synopsis
#  Installed Application Authentication
param($Credential)
   if(!(Test-Path Variable:Global:IAAccessToken)) {
      if(!$Credential) { $Credential = Get-Credential }
      
      $global:IAAccessToken = Invoke-OAuthHttp -Parameters @{
         ff_username   = $Credential.GetNetworkCredential().Username # the user's username
         ff_password   = $Credential.GetNetworkCredential().Password # the user's password
      } -Uri             $FriendFeedUris.AccessToken `
        -ConsumerKey     $global:PoshFFToken.oauth_consumer_key `
        -ConsumerSecret  $global:PoshFFToken.oauth_consumer_secret -Verb "POST"
   }   
   return $global:IAAccessToken
}



#  function get-messages {
   #  Invoke-OAuthorized https://www.yammer.com/api/v1/messages | tee -var messages
   #  $global:newestyammer = $messages.messages.message[0].id
   #  while($messages.messages.message.count -eq 20) {
      #  $global:oldestyammer = $messages.messages.message[-1].id
      #  sleep -sec 10
      #  Invoke-OAuthorized https://www.yammer.com/api/v1/messages -parameter @{ older_than = $oldestyammer } | tee -var messages
      #  if(!$?) { break }
   #  }
#  }

#  get-messages | Select sender-id, thread-id, attachments, created-at, client-type | Export-CSV Messages.csv
