function Get-FeedInfo([string[]]$feeds) {
# $feeds is an array of rss/atom URLs 
$blogs=@(); $broken=@(); $feeds = $feeds | sort -unique {$_}
foreach($feed in $feeds){ 
   try { 
      $xml = Get-WebPageContent $feed;
   } catch { 
      $broken += $feed
      $xml = $null
   }
   if($xml.html.rss) { $xml = $xml.html; write-warning $feed }
   if($xml.rss) {
      $blogs += New-Object PSObject -Property @{ 
         title= $xml.rss.channel.title
         link = $xml.rss.channel.link | ? { $_ -is [string] }
         feed = $feed 
      }
   } elseif($xml.feed) {
      $blogs += New-Object PSObject -Property @{ 
         title= $xml.feed.title.'#text'
         link = $xml.feed.link |? {$_.rel -eq 'alternate' } | select -expand href
         feed = $feed 
      }
   } else {
      $broken += $feed
      $blogs += New-Object PSObject -Property @{ feed = $feed }
   }
}
Write-Output $blogs, $broken
}
