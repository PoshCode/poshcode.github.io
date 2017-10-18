# author: Alexander Groß
# http://www.therightstuff.de/2008/07/25/RSS+Enclosure+Downloader+In+PowerShell.aspx
$feed=[xml](New-Object System.Net.WebClient).DownloadString("http://the/rss/feed/url")

foreach($i in $feed.rss.channel.item) {
	$url = New-Object System.Uri($i.enclosure.url)

	$url.ToString()
	$url.Segments[-1]

	(New-Object System.Net.WebClient).DownloadFile($url, $url.Segments[-1])
}

