param (
	$Path
)
[xml]$flt = Get-Content -Path $Path
$title = $flt.feed.title
$author = $flt.feed.author.name
$output = @()
foreach ( $entry in $flt.feed.entry ) {
	foreach ( $property in $entry.property ) {
		foreach ($item in $property) {
			$process = "" | select Id, Updated, Name, Value
			$process.Id = $entry.Id
			$process.Updated = [datetime]$entry.Updated
			$process.Name = $item.Name
			$process.Value = $item.Value
			$output += $process
		}
	}
}
$output
