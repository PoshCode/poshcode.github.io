
param( 
	[parameter(Mandatory=$true)]
	[string]
	$name,
	
	[parameter(Mandatory=$true,ValueFromPipeline=$true)]
	$file
)

begin
{
	$script:files = @();
}
process
{
	$script:files += $file.fullname;
}
end
{
	$count = $script:files.length;
	$mediaElements = $script:files | foreach{
		"<media src='$_' />"
	};
	
[xml]$playlist = @"
<?wpl version="1.0"?>
<smil>
    <head>
        <meta name="Generator" content="out-playlist.ps1"/>
        <meta name="IsNetworkFeed" content="0"/>
        <meta name="ItemCount" content="$count"/>
        <title>$name</title>
    </head>
    <body>
        <seq>
			$mediaElements
        </seq>
    </body>
</smil>
"@;
	new-item "~\documents\my music\playlists\$name.wpl" -value '' -type file -force | out-null;
	$playlist.save( ("~\documents\my music\playlists\$name.wpl" | resolve-path) );
}
