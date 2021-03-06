# Its a modification from the version in http://blogs.technet.com/jamesone/archive/2009/02/16/how-to-drive-twitter-or-other-web-tools-with-powershell.aspx
# usees https and gets all replies

Function Get-TwitterReply { 
 param ($username, $password)
 if ($WebClient -eq $null) {$Global:WebClient=new-object System.Net.WebClient  }
 $WebClient.Credentials = (New-Object System.Net.NetworkCredential -argumentList $username, $password)
 $page = 0
 $ret = @()
 do {  	$Page ++
    $replies = ([xml]$webClient.DownloadString("https://twitter.com/statuses/replies.xml?page=$Page")  ).statuses.status
    $ret += $replies
    Write-host  $replies.count
	} while ($replies.count -gt 0 ) # sometimes I get less than 20
 $ret
 write-host $ret.count
 # Returns the 20 most recent @replies for the authenticating user.
 #page:  Optional. Retrieves the 20 next most recent replies
 #since.  Optional.  Narrows the returned results to just those replies created after the specified HTTP-formatted date, up to 24 hours old.
 #since_id.  Optional.  Returns only statuses with an ID greater than (that is, more recent than) the specified ID.  Ex: http://twitter.com/statuses/replies.xml?since_id=12345
}

