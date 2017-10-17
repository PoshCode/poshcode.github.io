<#
-------------------------------------------------------------------------------
Name:    Social Media Scripting Framework
Module:  Twitter
Version: 0.2 BETA
Date:    2013/02/03
Author:  Carlos Veira Lorenzo
         e-mail:   cveira [at] thinkinbig [dot] org
         blog:     thinkinbig.org
         twitter:  @cveira
         facebook: www.facebook.com/cveira
         Google+:  gplus.to/cveira
         LinkedIn: es.linkedin.com/in/cveira/
-------------------------------------------------------------------------------
Support:
  http://thinkinbig.org/oms/

Forums & Communities:
  facebook.com/ThinkInBig
  gplus.to/ThinkInBig
  http://bit.ly/SMSF-Forum
-------------------------------------------------------------------------------
Code Mirror Sites:
  https://smsf.codeplex.com/
  https://github.com/cveira/social-media-scripting-framework
  https://code.google.com/p/social-media-scripting-framework/
  http://sourceforge.net/projects/smsf/
-------------------------------------------------------------------------------
Social Media Scripting Framework.
Copyright (C) 2013 Carlos Veira Lorenzo.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
-------------------------------------------------------------------------------
#>


[Reflection.Assembly]::LoadWithPartialName("System.Security") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("System.Net")      | Out-Null


[string] $TweetContentPattern = '((?s)<p[^>]*js-tweet-text tweet-text[^>]*>(?<TweetContent>.*?)</p>.*?'  + `
                                '<li[^>]*js-stat-count js-stat-retweets stat-count[^>]*>(?<ReTweetStats>.*?)</li>.*?' + `
                                '<li[^>]*js-stat-count js-stat-favorites stat-count[^>]*>(?<FavoritesStats>.*?)</li>)|' + `

                                '((?s)<p[^>]*js-tweet-text tweet-text[^>]*>(?<TweetContent>.*?)</p>.*?'  + `
                                '<li[^>]*js-stat-count js-stat-retweets stat-count[^>]*>(?<ReTweetStats>.*?)</li>)|' + `

                                '((?s)<p[^>]*js-tweet-text tweet-text[^>]*>(?<TweetContent>.*?)</p>.*?'  + `
                                '<li[^>]*js-stat-count js-stat-favorites stat-count[^>]*>(?<FavoritesStats>.*?)</li>)|' + `

                                '((?s)<p[^>]*js-tweet-text tweet-text[^>]*>(?<TweetContent>.*?)</p>)'


$TwitterTimeOut               = 3 * 60 * 1000 # seconds
$TwitterUserAgent             = "PowerShell"

# --------------------------------------------------------------------------------------------------

function Get-TweetRetweetsFromPage( [ref] $PageSourceCode ) {
  # $SourceCode = Get-PageSourceCode https://twitter.com/cveira/status/275929500183830529
  # Get-TweetRetweetsFromPage ([ref] $SourceCode)

  [string] $RetweetsCountPattern = '<strong[^>]*[^>]*>(?<RetweetsCount>.*?)</strong>'

  if ( $PageSourceCode.Value -match $TweetContentPattern ) {
    if ( $Matches.ReTweetStats -match $RetweetsCountPattern ) {
      $Matches.RetweetsCount
    } else {
      0
    }
  } else {
    0
  }
}


function Get-TweetFavoritesFromPage( [ref] $PageSourceCode ) {
  # $SourceCode = Get-PageSourceCode https://twitter.com/cveira/status/275929500183830529
  # Get-TweetFavoritesFromPage ([ref] $SourceCode)

  [string] $FavoritesCountPattern = '<strong[^>]*[^>]*>(?<FavoritesCount>.*?)</strong>'

  if ( $PageSourceCode.Value -match $TweetContentPattern ) {
    if ( $Matches.FavoritesStats -match $FavoritesCountPattern ) {
      $Matches.FavoritesCount
    } else {
      0
    }
  } else {
    0
  }
}


function Get-TweetContentFromPage( [ref] $PageSourceCode ) {
  # $SourceCode = Get-PageSourceCode https://twitter.com/cveira/status/275929500183830529
  # Get-TweetContentFromPage ([ref] $SourceCode)

  if ( $PageSourceCode.Value -match $TweetContentPattern ) {
    $Matches.TweetContent
  } else {
    "N/D"
  }
}


function Get-TweetLinksFromPage( [ref] $PageSourceCode ) {
  # $SourceCode = Get-PageSourceCode https://twitter.com/cveira/status/275929500183830529
  # Get-TweetLinksFromPage ([ref] $SourceCode)

  [RegEx]    $LinksPattern = '(data-expanded-url="(.*?)")+'
  [string[]] $TweetLinks   = @()


  if ( $PageSourceCode.Value -match $TweetContentPattern ) {
    $CurrentMatch = $LinksPattern.match($Matches.TweetContent)

    if (!$CurrentMatch.Success) {
      $TweetLinks +=  "N/D"
    }

    while ($CurrentMatch.Success) {
      $TweetLinks   += $CurrentMatch.Value.Split('"')[1]
      $CurrentMatch =  $CurrentMatch.NextMatch()
    }
  } else {
    $TweetLinks +=  "N/D"
  }

  $TweetLinks
}


function Get-TweetHashTagsFromPage( [ref] $PageSourceCode ) {
  # $SourceCode = Get-PageSourceCode https://twitter.com/cveira/status/275929500183830529
  # Get-TweetHashTagsFromPage ([ref] $SourceCode)

  [string]   $HashTagNamePattern = "%23(?<HashTag>.*?)&amp"
  [RegEx]    $LinksPattern       = '(href="(.*?)")+'
  [string[]] $TweetLinks         = @()


  if ( $PageSourceCode.Value -match $TweetContentPattern ) {
    $CurrentMatch = $LinksPattern.match($Matches.TweetContent)

    if (!$CurrentMatch.Success) {
      $TweetLinks +=  "N/D"
    }

    while ($CurrentMatch.Success) {
      if ( $CurrentMatch.Value -match $HashTagNamePattern ) { $TweetLinks   += $Matches.HashTag }

      $CurrentMatch =  $CurrentMatch.NextMatch()
    }
  } else {
    $TweetLinks +=  "N/D"
  }

  $TweetLinks
}

# --------------------------------------------------------------------------------------------------

function EscapeDataStringRfc3986( [string] $text ) {
  [string[]] $Rfc3986CharsToEscape = @( "!", "*", "'", "(", ")" )

  [string] $EscapedText = [System.Uri]::EscapeDataString($text)

  for ( $i = 0; $i -lt $Rfc3986CharsToEscape.Length; $i++ ) {
    $EscapedText = $EscapedText.Replace( $Rfc3986CharsToEscape[$i], [System.Uri]::HexEscape($Rfc3986CharsToEscape[$i]) )
  }

  $EscapedText
}


function Set-OAuthSignature( [string] $HttpRequestType, [string] $HttpEndpoint, [string] $HttpQueryString, [string] $OAuthNonce, [string] $OAuthTimeStamp, [string] $OAuthConsumerKey, [string] $OAuthConsumerSecret, [string] $OAuthToken, [string] $OAuthTokenSecret ) {
  [string[]] $HttpQueryStringParameters
  $ParameterString = @{}

  if ( $HttpQueryString.Length -gt 0 ) {
    $HttpQueryStringParameters = $HttpQueryString.Split("&")
    $HttpQueryStringParameters | ForEach-Object { $ParameterString.Add( $_.Split("=")[0], $_.Split("=")[1] ) }
  }

  $ParameterString.Add( "oauth_consumer_key",     $OAuthConsumerKey )
  $ParameterString.Add( "oauth_nonce",            $OAuthNonce )
  $ParameterString.Add( "oauth_signature_method", "HMAC-SHA1" )
  $ParameterString.Add( "oauth_timestamp",        $OAuthTimeStamp )
  $ParameterString.Add( "oauth_token",            $OAuthToken )
  $ParameterString.Add( "oauth_version",          "1.0" )

  $signature             =  $HttpRequestType + "&"

  # 1. The URL in the signature string HAS NO QUERY_STRING PARAMETERS

  $signature             += [System.Uri]::EscapeDataString($HttpEndpoint) + "&"

  # 2. All the parameters included in the QUERY_STRING {when calling [System.Net.WebRequest]::Create()} have to be included in the signature
  # 3. When building the signature string, parameters must be in alphabetical order.

  $ParameterString.Keys | Sort-Object | ForEach-Object {
    # [System.Uri]::EscapeDataString($_ + "=" + $ParameterString.$_ + "&") is not RFC3986 compliant in .NET < 4.x!
    # RFC3986 compliancy is documented in OAuth 1.0A, not in Twitter documentation!

    $signature    += EscapeDataStringRfc3986 $($_ + "=" + $ParameterString.$_ + "&")
  }

  $signature      = $signature.Substring(0, $signature.Length - 3)

  $SignatureKey   = [System.Uri]::EscapeDataString($OAuthConsumerSecret) + "&" + [System.Uri]::EscapeDataString($OAuthTokenSecret)

  $Hasher         = New-Object System.Security.Cryptography.HMACSHA1
  $Hasher.Key     = [System.Text.Encoding]::ASCII.GetBytes($SignatureKey)

  $OAuthSignature = [System.Convert]::ToBase64String($Hasher.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($signature)))

  $OAuthSignature
}


function Set-OAuthHeader( [string] $OAuthConsumerKey, [string] $OAuthNonce, [string] $OAuthSignature, [string] $OAuthTimeStamp, [string] $OAuthToken ) {
  $OAuthHeader   =  'OAuth '
  $OAuthHeader   += 'oauth_consumer_key="' + [System.Uri]::EscapeDataString($OAuthConsumerKey) + '", '
  $OAuthHeader   += 'oauth_nonce="' + [System.Uri]::EscapeDataString($OAuthNonce) + '", '
  $OAuthHeader   += 'oauth_signature="' + [System.Uri]::EscapeDataString($OAuthSignature) + '", '
  $OAuthHeader   += 'oauth_signature_method="HMAC-SHA1", '
  $OAuthHeader   += 'oauth_timestamp="' + [System.Uri]::EscapeDataString($OAuthTimeStamp) + '", '
  $OAuthHeader   += 'oauth_token="' + [System.Uri]::EscapeDataString($OAuthToken) + '", '
  $OAuthHeader   += 'oauth_version="1.0"'

  $OAuthHeader
}


function Get-RawTweetRetweetedByAsXml( [string] $TweetPermaLink ) {
  # Get-RawTweetRetweetedByAsXml https://twitter.com/cveira/status/275929500183830529

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1/statuses/" + $TweetPermaLink.Split("/")[5] + "/retweeted_by.xml"

  $HttpEndpoint                = $ApiURL
  $HttpQueryString             = ""

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim() | Select-String -NotMatch "api.twitter.com" | ForEach-Object { $TwitterRawResponse += $_ } | Out-Null

      $TwitterRawResponse
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTweetRetweetedBy( [string] $TweetPermaLink ) {
  # Get-RawTweetRetweetedBy https://twitter.com/cveira/status/275929500183830529

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1/statuses/" + $TweetPermaLink.Split("/")[5] + "/retweeted_by.xml"

  $HttpEndpoint                = $ApiURL
  $HttpQueryString             = ""

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim() | Select-String -NotMatch "api.twitter.com" | ForEach-Object { $TwitterRawResponse += $_ } | Out-Null

      [xml] $TwitterRawResponse | ForEach-Object { $_.users.user } | ForEach-Object {
        New-Object PSObject -Property @{
          Name        = $_.name
          ScreenName  = $_.screen_name
          Description = $_.description
          URL         = $_.url
          Friends     = $_.friends_count
          Followers   = $_.followers_count
          Tweets      = $_.statuses_count
          Listed      = $_.listed_count
        }
      }
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterMentionsAsJson {
  # https://dev.twitter.com/docs/api/1.1/get/statuses/mentions_timeline
  # Get-RawTwitterMentionsAsJson | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/statuses/mentions_timeline.json?count=20&include_entities=true&include_rts=true"

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTweetRetweetsAsJson( [string] $TweetPermaLink ) {
  # https://dev.twitter.com/docs/api/1.1/get/statuses/retweets/%3Aid
  # Get-RawTweetRetweetsAsJson https://twitter.com/cveira/status/275929500183830529 | ConvertFrom-Json
  # Get-RawTweetRetweetsAsJson http://twitter.com/TechCrunch/status/282712924752060417 | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/statuses/retweets/" + $TweetPermaLink.Split("/")[5] + ".json?count=100"

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterUserAsJson( [string] $UserName ) {
  # https://dev.twitter.com/docs/api/1.1/get/users/show
  # Get-RawTwitterUserAsJson cveira | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/users/show.json?screen_name=" + $UserName.Trim() + "&include_entities=true"

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTweetAsJson( [string] $TweetPermaLink ) {
  # https://dev.twitter.com/docs/api/1.1/get/statuses/show/%3Aid
  # Get-RawTweetAsJson https://twitter.com/cveira/status/275929500183830529 | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/statuses/show.json?id=" + $TweetPermaLink.Split("/")[5] + "&include_entities=true"

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterFavoritesAsJson( [string] $UserName ) {
  # https://dev.twitter.com/docs/api/1.1/get/favorites/list
  # Get-RawTwitterFavoritesAsJson cveira | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/favorites/list.json?count=20&screen_name=" + $UserName.Trim() + "&include_entities=true"

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTweetsFromUserAsJson( [string] $UserName, [int] $results = 20, [string] $FirstId = "", [string] $LastId = "" ) {
  # https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline
  # Get-RawTweetsFromUserAsJson cveira | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""
  [string] $FilterParameters   = ""

  if ( ( $FirstId -ne "" ) -and ( $FirstId -match "\d+" ) ) { $FilterParameters += "&max_id="   + $FirstId }
  if ( ( $LastId  -ne "" ) -and ( $LastId  -match "\d+" ) ) { $FilterParameters += "&since_id=" + $LastId  }

  [string] $ApiURL             = "http://api.twitter.com/1.1/statuses/user_timeline.json?include_entities=true&include_rts=true&exclude_replies=true&count=" + $results + $FilterParameters + "&screen_name=" + $UserName.Trim()

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterTimeLineAsJson {
  # https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline
  # Get-RawTwitterTimeLineAsJson | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/statuses/home_timeline.json?include_entities=true&count=20"

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterSearchAsJson( [string] $query, [int] $ResultsPerPage = 20, [string] $Language = "", [string] $ResultType = "", [string] $StartDate = "", [string] $GeoCode = "", [int64] $SinceId = 0, [int64] $MaxId = 0 ) {
  # https://dev.twitter.com/docs/api/1.1/get/search/tweets
  # https://dev.twitter.com/docs/using-search
  # https://dev.twitter.com/docs/working-with-timelines

  # Get-RawTwitterSearchAsJson cveira | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""


  [string] $SearchParameters   = "include_entities=true"

  if ( $ResultType -eq "" ) {
    $SearchParameters += "&result_type=mixed"
  } else {
    switch ( $ResultType ) {
      "mixed"   { $SearchParameters += "&result_type=mixed"   }
      "recent"  { $SearchParameters += "&result_type=recent"  }
      "popular" { $SearchParameters += "&result_type=popular" }
      default   { $SearchParameters += "&result_type=mixed"   }
    }
  }

  if ( ( $StartDate -ne "" ) -and ( $StartDate -match "\d{4}-\d{2}-\d{2}" ) ) {
    $SearchParameters += "&until=" + $StartDate
  }

  if ( ( $GeoCode -ne "" ) -and ( $GeoCode -match "(\-*[\d\.]+),(\-*[\d\.]+),(\d+)(km|mi)" ) ) {
    $SearchParameters += "&geocode=" + $GeoCode
  }

  if ( $SinceId -ne 0 ) {
    $SearchParameters += "&since_id=" + $SinceId
  }

  if ( $MaxId -ne 0 ) {
    $SearchParameters += "&max_id=" + $MaxId
  }

  $SearchParameters   += "&count=" + $ResultsPerPage + "&q="

  [string] $ApiURL     = "http://api.twitter.com/1.1/search/tweets.json?" + $SearchParameters + [System.Uri]::EscapeDataString($query.Trim())

  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint      = $ApiURL.Split("?")[0]
    $HttpQueryString   = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint      = $ApiURL
    $HttpQueryString   = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Send-Tweet ( [string] $TweetMessage ) {
  # https://dev.twitter.com/docs/api/1.1/post/statuses/update
  # Send-Tweet "This is my first Tweet from #PowerShell using, raw #DotNet and #OAuth!"

  [string] $HttpRequestType    = "POST"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/statuses/update.json"


  if ( $TweetMessage.Length -gt 140 ) {
    $TweetMessage              = $TweetMessage.Substring(0,140)
  }

  # Body POST Data format is NOT documented!
  # look at how the supplied example looks like @ https://dev.twitter.com/docs/api/1.1/post/statuses/update
  [byte[]] $HttpPostBody       = [System.Text.Encoding]::UTF8.GetBytes( "status=" + ( EscapeDataStringRfc3986 ($TweetMessage) ) )
  $HttpEndpoint                = $ApiURL

  # The 'status' parameter gets encoded TWICE in the OAuth signature. This detail is NOT documented!
  # Run an example with the OAuth Tool and look at the results for the OAuth signature.
  # [System.Uri]::EscapeDataString() is not RFC3986 compliant in .NET < 4.x!
  # RFC3986 compliancy is documented in OAuth 1.0A, not in Twitter documentation!
  $HttpQueryString             = "status=" + (EscapeDataStringRfc3986 $TweetMessage)

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request    = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                         = $HttpRequestType
  $request.UserAgent                      = $TwitterUserAgent
  $request.Timeout                        = $TwitterTimeOut
  $request.ContentType                    = "application/x-www-form-urlencoded"
  $request.ContentLength                  = $HttpPostBody.Length
  $request.ServicePoint.Expect100Continue = $false
  $request.Headers.Add("Authorization", $OAuthHeader)


  try {
    [System.IO.Stream] $RequestBody = $request.GetRequestStream()

    $RequestBody.Write($HttpPostBody, 0, $HttpPostBody.Length)
    # $RequestBody.Flush()
    $RequestBody.Close()

    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterListSubscribersAsJson( [string] $TweetPermaLink, [string] $PageId = "-1" ) {
  # https://dev.twitter.com/docs/api/1.1/get/lists/subscribers
  # Get-RawTwitterListSubscribersAsJson https://twitter.com/cveira/cloud | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/lists/subscribers.json?slug=" + $TweetPermaLink.Split("/")[4] + "&owner_screen_name=" + $TweetPermaLink.Split("/")[3] + "&include_entities=true&cursor=" + $PageId + "&skip_status=true"


  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterListMembersAsJson( [string] $TweetPermaLink, [string] $PageId = "-1" ) {
  # https://dev.twitter.com/docs/api/1.1/get/lists/members
  # Get-RawTwitterListMembersAsJson https://twitter.com/cveira/cloud | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/lists/members.json?slug=" + $TweetPermaLink.Split("/")[4] + "&owner_screen_name=" + $TweetPermaLink.Split("/")[3] + "&include_entities=true&cursor=" + $PageId + "&skip_status=true"


  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterListTimeLineAsJson( [string] $TweetPermaLink, [int] $ResultsPerPage = 20 ) {
  # https://dev.twitter.com/docs/api/1.1/get/lists/statuses
  # Get-RawTwitterListTimeLineAsJson https://twitter.com/cveira/cloud | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/lists/statuses.json?slug=" + $TweetPermaLink.Split("/")[4] + "&owner_screen_name=" + $TweetPermaLink.Split("/")[3] + "&count=" + $ResultsPerPage + "&include_entities=true&include_rts=true"


  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterUserFriendsFromUserAsJson( [string] $UserName, [string] $PageId = "-1" ) {
  # https://dev.twitter.com/docs/api/1.1/get/friends/list
  # Get-RawTwitterUserFriendsFromUserAsJson cveira | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/friends/list.json?screen_name=" + $UserName.Trim() + "&include_entities=true&cursor=" + $PageId + "&skip_status=true"


  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterFollowersFromUserAsJson( [string] $UserName, [string] $PageId = "-1" ) {
  # https://dev.twitter.com/docs/api/1.1/get/followers/list
  # Get-RawTwitterFollowersFromUserAsJson cveira | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/followers/list.json?screen_name=" + $UserName.Trim() + "&include_entities=true&cursor=" + $PageId + "&skip_status=true"


  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


function Get-RawTwitterUserAsJson( [string] $UserName ) {
  # https://dev.twitter.com/docs/api/1.1/get/users/show
  # Get-RawTwitterUserAsJson cveira | ConvertFrom-Json

  [string] $HttpRequestType    = "GET"
  [string] $HttpEndpoint       = ""
  [string] $HttpQueryString    = ""
  [string] $TwitterRawResponse = ""

  [string] $ApiURL             = "http://api.twitter.com/1.1/users/show.json?screen_name=" + $UserName.Trim() + "&include_entities=true"


  if ( $ApiURL.IndexOf("?") -ne -1 ) {
    $HttpEndpoint           = $ApiURL.Split("?")[0]
    $HttpQueryString        = $ApiURL.Split("?")[1]
  } else {
    $HttpEndpoint           = $ApiURL
    $HttpQueryString        = ""
  }

  $OAuthConsumerKey            = $TwitterConsumerKey
  $OAuthConsumerSecret         = $TwitterConsumerSecret
  $OAuthToken                  = $TwitterAccessToken
  $OAuthTokenSecret            = $TwitterAccessTokenSecret

  $OAuthNonce                  = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([System.DateTime]::Now.Ticks.ToString()))
  $TimeStamp                   = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null).ToUniversalTime()
  $OAuthTimeStamp              = [System.Convert]::ToInt64($TimeStamp.TotalSeconds).ToString()

  $OAuthSignature              = Set-OAuthSignature $HttpRequestType $HttpEndpoint $HttpQueryString $OAuthNonce $OAuthTimeStamp $OAuthConsumerKey $OAuthConsumerSecret $OAuthToken $OAuthTokenSecret
  $OAuthHeader                 = Set-OAuthHeader    $OAuthConsumerKey $OAuthNonce $OAuthSignature $OAuthTimeStamp $OAuthToken

  [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ApiURL)
  $request.Method                      = $HttpRequestType
  $request.UserAgent                   = $TwitterUserAgent
  $request.Timeout                     = $TwitterTimeOut
  $request.ContentType                 = "application/x-www-form-urlencoded"
  $request.Headers.Add("Authorization", $OAuthHeader)

  try {
    [System.Net.HttpWebResponse] $response = $request.GetResponse()

    if ( $response -ne $null ) {
      $ResponseStream = New-Object System.IO.StreamReader($response.GetResponseStream())
      $ResponseStream.ReadToEnd().Trim()
    }

    $response.Close()
  } catch {
    $_.Exception.Message
  }
}


# --------------------------------------------------------------------------------------------------


function Get-TwitterProfile( [string] $UserName ) {
  Get-RawTwitterUserAsJson $UserName | ConvertFrom-JSON
}


function Get-UnpagedFollowerList( [object[]] $PagedFollowersList ) {
  $UnpagedFollowers = @()

  $PagedFollowersList | ForEach-Object { $UnpagedFollowers += $_.users }
  $UnpagedFollowers = $UnpagedFollowers | Select-Object * -unique

  $UnpagedFollowers
}


function Get-TwitterFollowers( [string] $UserName ) {
  begin {
    [PSCustomObject[]] $RawFollowersPages = @()
    $CurrentPage                          = $null
    $TimeToWait                           = 66
    $FollowersPerPage                     = 20
    $PageCount                            = 0
    [int] $TotalFollowers                 = ( Get-RawTwitterUserAsJson $UserName | ConvertFrom-JSON ).followers_count
  }

  process {
    try {
      $PageCount            = 1
      $CurrentPage          = Get-RawTwitterFollowersFromUserAsJson $UserName | ConvertFrom-JSON
      $RawFollowersPages   += $CurrentPage

      do {
        Write-Progress -Activity "Retrieving Followers ..." -Status "Progress: " -PercentComplete ( (($PageCount * $FollowersPerPage) / $TotalFollowers) * 100 )

        $PageCount++

        $RawFollowersPages += $CurrentPage

        Start-Sleep -Seconds $TimeToWait

        $CurrentPage        = Get-RawTwitterFollowersFromUserAsJson $UserName -PageId $CurrentPage.next_cursor | ConvertFrom-JSON
      } until ( $CurrentPage.next_cursor -eq 0 )
    } catch {
      [PSCustomObject[]] $RawFollowersPages = @()
      $_.Exception.Message
    }
  }

  end {
    Get-UnpagedFollowerList $RawFollowersPages
    # $RawFollowersPages
  }
}


function Get-TweetsFromUser( [string] $UserName, [int] $results = 20, [switch] $quick, [switch] $IncludeAll ) {
  # Get-TweetsFromUser cveira -results 250 -quick

  # $DebugPreference = "Continue"

  [PSObject[]] $TimeLine = @()
  [PSObject[]] $tweets   = @()
  $SourcePattern         = '((?s)<a[^>]*[^>]*>(?<TweetSource>.*?)</a>)'

  $TwitterMaxResults     = 100
  $TimeToWait            = 6
  $ExtendedTimeToWait    = 0
  $TimeToWaitForRTs      = 66
  $TimeToWaitForFavs     = 66

  $IncludeRTs            = $false
  $IncludeFavorites      = $false

  if ( $quick ) {
    $IncludeAll          = $false
    $IncludeRTs          = $false
    $IncludeFavorites    = $false
  } elseif ( $IncludeAll ) {
    $IncludeRTs          = $true
    $IncludeFavorites    = $true
  }

  if ( $TimeToWaitForRTs -ge $TimeToWaitForFavs ) {
    $ExtendedTimeToWait  = $TimeToWaitForRTs
  } else {
    $ExtendedTimeToWait  = $TimeToWaitForFavs
  }


  if ( $results -lt $TwitterMaxResults ) {
    $tweets = Get-RawTweetsFromUserAsJson -UserName $UserName -results $results | ConvertFrom-Json
  } else {
    do {
      Write-Progress -Activity "Retrieving Tweets ..." -Status "Progress: $($tweets.Count) / $results" -PercentComplete ( ( $($tweets.Count) / $results ) * 100 )

      $CurrentTweets   = Get-RawTweetsFromUserAsJson -UserName $UserName -results $TwitterMaxResults -FirstId $LastId | ConvertFrom-Json

      Write-Debug "[INFO] Retrieved Tweets:    $($tweets.Count)"
      Write-Debug "[INFO] CurrentTweets count: $($CurrentTweets.Count)"
      Write-Debug "[INFO] LastId:              $LastId"
      Write-Debug "[INFO] FirstId:             $($CurrentTweets[0].id)"

      if ( $CurrentTweets[0].id -eq $LastId ) {
        $FirstTweet    = 1
      } else {
        $FirstTweet    = 0
      }

      $LastId          = $CurrentTweets[ ( $CurrentTweets.Count - 1 ) ].id
      $tweets         += $CurrentTweets[ $FirstTweet..($CurrentTweets.Count - 1) ]

      Start-Sleep -Seconds $TimeToWait
    } until ( $tweets.Count -gt $results )

    $tweets            = $tweets[0..( $results - 1 )]
  }

  if ( $quick ) {
    $tweets
  } else {
    $i = 1

    $tweets | ForEach-Object {
      if ( $IncludeAll ) {
        Write-Progress -Activity "Normalizing Information ..." -Status "Progress: $i / $results - ETC: $( (( $results - $i ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes - Time Elapsed: $( (( $i - 1 ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes" -PercentComplete ( ( $i / $results ) * 100 )
      } else {
        Write-Progress -Activity "Normalizing Information ..." -Status "Progress: $i / $results" -PercentComplete ( ( $i / $results ) * 100 )
      }

      $NewTweet = $_

      $NewTweet.user     = $NewTweet.user.screen_name

      if ( $NewTweet.source -match $SourcePattern ) {
        $NewTweet.source = $Matches.TweetSource
      }

      Write-Debug ".Links not exists:          $( $NewTweet.Links -eq $null )"

      if ( $NewTweet.Links -eq $null ) {
        $NewTweet | Add-Member -NotePropertyName Links     -NotePropertyValue $NewTweet.entities.urls.expanded_url
      } else {
        $NewTweet.Links = $NewTweet.entities.urls.expanded_url
      }

      Write-Debug ".HashTags not exists:       $( $null -eq $NewTweet.HashTags )"

      if ( $null -eq $NewTweet.HashTags ) {
        $NewTweet | Add-Member -NotePropertyName HashTags  -NotePropertyValue $NewTweet.entities.hashtags.text -force
      } else {
        $NewTweet.HashTags = $NewTweet.entities.hashtags.text
      }

      Write-Debug ".Mentions not exists:       $( $null -eq $NewTweet.Mentions )"

      if ( $null -eq $NewTweet.Mentions ) {
        $NewTweet | Add-Member -NotePropertyName Mentions  -NotePropertyValue $NewTweet.entities.user_mentions.screen_name -force
      } else {
        $NewTweet.Mentions = $NewTweet.entities.user_mentions.screen_name
      }

      Write-Debug ".PermaLink not exists:      $( $NewTweet.PermaLink -eq $null )"

      if ( $NewTweet.retweeted_status.user.screen_name -eq $null ) {
        if ( $NewTweet.PermaLink -eq $null ) {
          $NewTweet | Add-Member -NotePropertyName PermaLink -NotePropertyValue "https://twitter.com/$($NewTweet.user)/status/$($NewTweet.id)"
        } else {
          $NewTweet.PermaLink = "https://twitter.com/$($NewTweet.user)/status/$($NewTweet.id)"
        }
      } else {
        if ( $NewTweet.PermaLink -eq $null ) {
          $NewTweet | Add-Member -NotePropertyName PermaLink -NotePropertyValue "https://twitter.com/$($NewTweet.retweeted_status.user.screen_name)/status/$($NewTweet.retweeted_status.id)"
        } else {
          $NewTweet.PermaLink = "https://twitter.com/$($NewTweet.retweeted_status.user.screen_name)/status/$($NewTweet.retweeted_status.id)"
        }
      }


      Write-Debug "[INFO] PermaLink:           $($NewTweet.PermaLink)"

      if ( $IncludeRTs ) {
        if ( $IncludeAll ) {
          Write-Progress -Activity "Retrieving Retweets ..." -Status "Progress: $i / $results - ETC: $( (( $results - $i ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes - Time Elapsed: $( (( $i - 1 ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes" -PercentComplete ( ( $i / $results ) * 100 )
        } else {
          Write-Progress -Activity "Retrieving Retweets ..." -Status "Progress: $i / $results" -PercentComplete ( ( $i / $results ) * 100 )
        }

        Write-Debug ".retweets not exists:       $( $NewTweet.entities.retweets -eq $null )"

        if ( $NewTweet.entities.retweets -eq $null ) {
          $NewTweet.entities | Add-Member -NotePropertyName retweets -NotePropertyValue @()
        } else {
          $NewTweet.entities.retweets = @()
        }

        Write-Debug ".Interactions not exists:   $( $NewTweet.Interactions -eq $null )"

        if ( $NewTweet.Interactions -eq $null ) {
          $NewTweet | Add-Member -NotePropertyName Interactions -NotePropertyValue @()
        } else {
          $NewTweet.Interactions = @()
        }


        $NewTweet.entities.retweets = Get-RawTweetRetweetsAsJson $NewTweet.PermaLink | ConvertFrom-Json
        # $NewTweet.retweet_count     = $NewTweet.entities.retweets.Count
        $NewTweet.Interactions     += $NewTweet.entities.retweets | ForEach-Object {
          New-Object PSObject -Property @{
            screen_name = $_.user.screen_name
            location    = $_.user.location
          }
        }

        Write-Debug "[INFO] Retrieved Retweets:  $($NewTweet.entities.retweets.Count)"
        Write-Debug "[INFO] Interactions:        $($NewTweet.Interactions.Count)"
      }

      if ( $IncludeFavorites ) {
        if ( $IncludeAll ) {
          Write-Progress -Activity "Retrieving Favorites ..." -Status "Progress: $i / $results - ETC: $( (( $results - $i ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes - Time Elapsed: $( (( $i - 1 ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes" -PercentComplete ( ( $i / $results ) * 100 )
        } else {
          Write-Progress -Activity "Retrieving Favorites ..." -Status "Progress: $i / $results" -PercentComplete ( ( $i / $results ) * 100 )
        }

        Write-Debug ".favorites_count not exists: $( $NewTweet.favorites_count -eq $null )"

        if ( $NewTweet.favorites_count -eq $null ) {
          $NewTweet | Add-Member -NotePropertyName favorites_count -NotePropertyValue 0
        } else {
          $NewTweet.favorites_count = 0
        }


        $SourceCode               = Get-PageSourceCode $NewTweet.PermaLink
        $NewTweet.favorites_count = Get-TweetFavoritesFromPage ([ref] $SourceCode)

        Write-Debug "[INFO] Retrieved Favorites: $($NewTweet.favorites_count)"
      }

      if ( $IncludeAll ) { Start-Sleep -Seconds $ExtendedTimeToWait }

      $TimeLine += $NewTweet
      $i++
    }

    $TimeLine
  }

  # $DebugPreference = "SilentlyContinue"
}


function Normalize-TwitterTimeLine( [PSObject[]] $TimeLine, [switch] $IncludeAll ) {
  # $TimeLine = Normalize-TwitterTimeLine $tweets -IncludeAll

  # $DebugPreference = "Continue"

  [PSObject[]] $NewTimeLine = @()

  $TimeToWait               = 0
  $TimeToWaitForRTs         = 66
  $TimeToWaitForFavs        = 66

  $SourcePattern            = '((?s)<a[^>]*[^>]*>(?<TweetSource>.*?)</a>)'
  $i                        = 1

  $IncludeRTs               = $false
  $IncludeFavorites         = $false

  if ( $IncludeAll ) {
    $IncludeRTs             = $true
    $IncludeFavorites       = $true
  }

  if ( $TimeToWaitForRTs -ge $TimeToWaitForFavs ) {
    $TimeToWait             = $TimeToWaitForRTs
  } else {
    $TimeToWait             = $TimeToWaitForFavs
  }


  $TimeLine | ForEach-Object {
    $NewTweet = $_

    if ( $IncludeAll ) {
      Write-Progress -Activity "Normalizing Information ..." -Status "Progress: $i / $($TimeLine.Count) - ETC: $( (( $TimeLine.Count - $i ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes - Time Elapsed: $( (( $i - 1 ) *  ( $TimeToWaitForRTs + $TimeToWaitForFavs )) / 60 ) minutes" -PercentComplete ( ( $i / $TimeLine.Count ) * 100 )
    } else {
      Write-Progress -Activity "Normalizing Information ..." -Status "Progress: $i / $($TimeLine.Count)" -PercentComplete ( ( $i / $TimeLine.Count ) * 100 )
    }


    $NewTweet.user     = $NewTweet.user.screen_name

    if ( $NewTweet.source -match $SourcePattern ) {
      $NewTweet.source = $Matches.TweetSource
    }

    Write-Debug ".Links not exists:          $( $NewTweet.Links -eq $null )"

    if ( $NewTweet.Links -e
