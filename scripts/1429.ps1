
#put the playlist.com playlist number into $pl
$pl = 14870805259;

([xml](new-object system.net.webclient).downloadstring("http://pl.playlist.com/pl.php?playlist=$([int]($pl/256))")).playlist.tracklist.track | % {try { $a= $_.tracktitle;$a;(new-object system.net.webclient).downloadfile($_.originallocation,"c:\musiccache\$a.mp3") } catch { } } 
