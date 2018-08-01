$ITunes = New-Object -ComObject iTunes.Application
# The count is dynamic when you call this so you can't use it in the loop
# as you're deleting things or else Write-Progress throws errors at the end
$ItemCount = $ITunes.LibraryPlaylist.Tracks.Count 
$toDelete = @()
1..$ITunes.LibraryPlaylist.Tracks.Count | % {
    # Can't delete reliably in this loop since item numbers
    # get changed as you delete items causing items to be skipped
	$CurrentTrack = $ITunes.LibraryPlaylist.Tracks.Item($_)

	# File Track ??
	if ( $CurrentTrack.Kind -eq 1 )
		{
		if ( ! ([System.IO.File]::Exists($CurrentTrack.Location)) ) 
			{
			Write-Host "$($CurrentTrack.Artist) - $($CurrentTrack.Name) will be deleted."
			    $toDelete += New-Object -TypeName PSObject -Property (@{
                    Name   = $CurrentTrack.Name
                    Artist = $CurrentTrack.Artist
                    HighID = $ITunes.ITObjectPersistentIDHigh($CurrentTrack)
                    LowID  = $ITunes.ITObjectPersistentIDLow($CurrentTrack)
                    Path   = $CurrentTrack.Location
                })
			}
		}
	Write-Progress -activity "Collecting Dead Tracks" -status "$($CurrentTrack.Artist) - $($CurrentTrack.Name)" -percentComplete ( $_/$ItemCount*100)

}
$i = 0
$toDelete | % {
     Write-Progress -activity "Deleting Dead Tracks" -status "$($_.Artist) - $($_.Name)" -percentComplete (($i++)/$toDelete.Count*100)
     $ITunes.LibraryPlaylist.Tracks.ItemByPersistentID($_.HighID,$_.LowID).Delete()
}
