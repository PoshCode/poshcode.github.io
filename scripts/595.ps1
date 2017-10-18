Clear
$ITunes = New-Object -ComObject iTunes.Application

1..$ITunes.LibraryPlaylist.Tracks.Count | % {
	$CurrentTrack = $ITunes.LibraryPlaylist.Tracks.Item($_)

	# File Track ??
	if ( $CurrentTrack.Kind -eq 1 )
		{
		if ( ! ([System.IO.File]::Exists($CurrentTrack.Location)) ) 
			{
			Write-Host "$($CurrentTrack.Artist) - $($CurrentTrack.Name) has been deleted."
			$CurrentTrack.Delete()
			}
		}
	Write-Progress -activity "Removing Dead Tracks" -status "$($CurrentTrack.Artist) - $($CurrentTrack.Name)" -percentComplete ( $_/$ITunes.LibraryPlaylist.Tracks.Count*100)

}
