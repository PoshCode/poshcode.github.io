# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Chad Miller 
### </Author>
### <Description>
### Checks an RSS feed and sends the feed information through email if it hasn't
### been seen before.
### </Description>
### <Usage>
###  ./rss2email.ps1 'mailrelay.acme.com' "$ProfileDir\guidcache.txt" "myemail@acme.com" "http://rss.cnn.com/rss/cnn_topstories.rss/
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param ($smtpServer, $rssCacheFile, $recipients, $rssUrl)

#######################
function Get-MD5
{
    param ($str)
    $cryptoServiceProvider = [System.Security.Cryptography.MD5CryptoServiceProvider]

    $hashAlgorithm = new-object $cryptoServiceProvider
    $byteArray = [Text.Encoding]::UTF8.GetBytes($str)
    $hashByteArray = $hashAlgorithm.ComputeHash($byteArray)
    $hex = $null
    $hashByteArray | foreach {$hex += $_.ToString("X2")}
    $hex

} #Get-MD5

#######################
function Get-Rss
{
    $feed = [xml](new-object System.Net.WebClient).DownloadString($rssUrl)
    #Set the description to the empty string, since it contains html markup
    $feed.rss.channel.Item | foreach {$_.description = ""}
    #Convert the rss.channel item to a string
    $results = $feed.rss.channel.Item | Out-String
    $title = $feed.rss.channel.title
    #if guid available we could do something like $feed.rss.GetElementsByTagName("guid") | % {$_.get_InnerXml()}
    #however some rss feeds don't have guids so we'll generate hex hash to uniquely identify the rss feed
    #return a hash table with array
    @{$(Get-MD5 $results) = @($title,$results)}

} #Get-Rss

#######################
function Send-RssEmail
{
    param ($recipients,$subject,$message)
    $smtpmail = [System.Net.Mail.SMTPClient]("$smtpServer")
    $smtpmail.Send($recipients, $recipients, $subject, $message)

} #Send-RssEmail

#######################
function Get-RssCache
{
    if (test-path $rssCacheFile) {
       $guidcache = Get-Content $rssCacheFile
    } else {
       $guidcache = @()
    }

    return $guidcache

} #Get-RssCache

#######################
$rss = $(Get-Rss $rssUrl)

$guidcache = $(Get-RssCache)

#If we haven't read seen this rss feed, send an email then add the feed MD5 hash to our cache file so we won't send it again
if (!($guidcache -contains $rss.keys))
{
   Send-RssEmail $recipients $($rss.values)[0] $($rss.values)[1]
   $rss.keys >> $rssCacheFile
}

