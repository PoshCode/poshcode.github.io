if(@(Import-ConstructorFunctions -Path "$PSScriptRoot\Types_Generated").Count -lt 3) {
Add-ConstructorFunction  -T Hammock.Authentication.OAuth.OAuthCredentials, Hammock.RestClient, Hammock.RestRequest -Path "$PSScriptRoot\Types_Generated"
}

$RequestToken = "request_token"
$AccessToken   = "access_token"
$Authorize     = "authorize"



#  $Yammer = @{
#    Authority      = "https://www.yammer.com/oauth"
#    ConsumerKey    = 'aaaaaaaaaaaaaaaaaaaa'
#    ConsumerSecret = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
#  }
#  $Twitter = new-object PSObject -Property @{
#    Authority      = 'https://api.twitter.com/oauth/'
#    ConsumerKey    = 'aaaaaaaaaaaaaaaaaaaaa'
#    ConsumerSecret = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
#  } | Get-OAuthCredentials


function Get-OAuthCredentials {
#.Synopsis
#  Get verified OAuth credentials from an OAuth service
#.Description
#  Gets verified OAuth credentials from an OAuth service using the desktop "Verified App" system
[CmdletBinding()]
param(
   [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [string]$Authority                              
,                                          
   [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias('Key')]                          
   [string]$ConsumerKey                            
,                                          
   [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias('Secret')]
   [string]$ConsumerSecret
)
process {
   $CachePath = Join-Path $PSScriptRoot "$(($Authority -as [Uri]).Authority).clixml"
   if(Test-Path $CachePath) {
      return Import-CliXml $CachePath
   }

   ##############################################
   ### STEP 1: Request a user token
   $cred1   = New-OAuthCredentials -Type RequestToken -SignatureMethod HmacSha1 -ConsumerKey $ConsumerKey -ConsumerSecret $ConsumerSecret
   $client  = New-RestClient -Cred $cred1 -Authority $Authority
   # $client.AddField( "format", "xml" )  ## this doesn't work for some reason
   $request = New-RestRequest -Path $RequestToken

   $RequestResponse = $client.Request( $request )

   ##############################################
   ### STEP 2: Get the user to verify that token
   $RequestAuth = [System.Web.HttpUtility]::ParseQueryString($RequestResponse.Content)
   $AuthURL =  "{0}/{1}?oauth_token={2}" -f $Authority.TrimEnd('/'), $Authorize, $RequestAuth['oauth_token']
   Start $AuthURL
   $AccessVerifier = Read-Host "Please enter the token from the web site: $AuthURL"

   ##############################################
   ### STEP 3: Get an access token
   $cred2   = New-OAuthCredentials -Type AccessToken -SignatureMethod HmacSha1 -Verifier $AccessVerifier `
                 -ConsumerKey $ConsumerKey -ConsumerSecret $ConsumerSecret `
                 -Token  $RequestAuth['oauth_token'] -TokenSecret $RequestAuth['oauth_token_secret'] 

   $client  = New-RestClient -Cred $cred2 -Authority $Authority
   # $client.AddField( "format", "xml" )  ## this doesn't work for some reason
   $request = New-RestRequest -Path $AccessToken

   $AccessResponse = $client.Request( $request )
   $AccessAuth     = [System.Web.HttpUtility]::ParseQueryString($AccessResponse.Content)

   ##############################################
   ### STEP 4: Now stash that stuff somewhere!
   $credentials    = New-OAuthCredentials -Type AccessToken -SignatureMethod HmacSha1 `
                     -ConsumerKey $ConsumerKey -ConsumerSecret $ConsumerSecret `
                     -Token  $RequestAuth['oauth_token'] -TokenSecret $RequestAuth['oauth_token_secret'] 

   Export-CliXml $CachePath -Input $Credentials
   return $credentials
}}
