function Get-HttpResponseUri {
#.Synopsis
#   Fetch the HEAD for a url and return the ResponseUri.
#.Description
#   Does a HEAD request for a URL, and returns the ResponseUri. This is useful for resolving (in a service-independent way) shortened urls.
#.Parameter ShortUrl
#   A (possibly) shortened URL to be resolved to its redirect location.
   PARAM(
      [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
      [Alias("Uri","Url")]
      [string]$ShortUrl
   )
   $req = [System.Net.HttpWebRequest]::Create($ShortUrl)
   $req.Method = "HEAD"
   $response = $req.GetResponse()
   Write-Output $response.ResponseUri
   $response.Close() # clean up like a good boy
}

