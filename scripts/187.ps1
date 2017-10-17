###################################
## Figure out the real url behind those shortened forms
function Resolve-URL([string[]]$urls) { 
   [regex]$snip  = "(?:https?://)?(?:snurl|snipr|snipurl)\.com/([^?/ ]*)\b"
   [regex]$tiny  = "(?:https?://)?TinyURL.com/([^?/ ]*)\b"
   [regex]$isgd  = "(?:https?://)?is.gd/([^?/ ]*)\b"
   [regex]$twurl = "(?:https?://)?twurl.nl/([^?/ ]*)\b"

   switch -regex ($urls) {
      $snip {
         write-output $snip.Replace( $_, (new-object System.Net.WebClient
            ).DownloadString("http://snipurl.com/resolveurl?id=$($snip.match( $_ ).groups[1].value)"))
      }
      $tiny {
         $doc = ConvertFrom-Html "http://tinyurl.com/preview.php?num=$($tiny.match( $_ ).groups[1].value)"
         write-output $tiny.Replace( $_, "$($doc.SelectSingleNode(""//a[@id='redirecturl']"").href)" )
      }
      $isgd {
         $doc = ConvertFrom-Html "http://is.gd/$($isgd.match( $_ ).groups[1].value)-"
         write-output $isgd.Replace( $_, "$($doc.SelectSingleNode(""//div[@id='main']/p/a"").href)") 
      }
      $twurl {
         $doc = ConvertFrom-Html "http://tweetburner.com/links/$($twurl.match( $_ ).groups[1].value)"
         write-output $twurl.Replace($_, "$($doc.selectsingleNode(""//div[@id='main-content']/p/a"").href)" )
      }
      default { write-output $_ }
   }
}

