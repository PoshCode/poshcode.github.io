# Creates an RSS feed
# Parameter input is for "site": Path, Title, Url, Description
# Pipeline input is for feed items: hashtable with Title, Link, Author, Description, and pubDate keys
param (
	$Path = "$( throw 'Path is a mandatory parameter.' )",
	$Title = "Site Title",
	$Url = "http://$( $env:computername )",
	$Description = "Description of site"
)
Begin {
	# feed metadata
	$encoding = [System.Text.Encoding]::UTF8
	$writer = New-Object System.Xml.XmlTextWriter( $Path, $encoding )
	$writer.WriteStartDocument()
	$writer.WriteStartElement( "rss" )
	$writer.WriteAttributeString( "version", "2.0" )
	$writer.WriteStartElement( "channel" )
	$writer.WriteElementString( "title", $Title )
	$writer.WriteElementString( "link", $Url )
	$writer.WriteElementString( "description", $Description )
}
Process {
	# Construct feed items
	$writer.WriteStartElement( "item" )
	$writer.WriteElementString( "title",	$_.title )
	$writer.WriteElementString( "link",		$_.link )
	$writer.WriteElementString( "author",	$_.author )
	$writer.WriteStartElement( "description" )
	$writer.WriteRaw( "<![CDATA[" ) # desc can contain HTML, so its escaped using SGML escape code
	$writer.WriteRaw( $_.description )
	$writer.WriteRaw( "]]>" )
	$writer.WriteEndElement()
	$writer.WriteElementString( "pubDate", $_.pubDate.toString( 'r' ) )
	$writer.WriteElementString( "guid", $homePageUrl + "/" + [guid]::NewGuid() )
	$writer.WriteEndElement()
}
End {
	$writer.WriteEndElement()
	$writer.WriteEndElement()
	$writer.WriteEndDocument()
	$writer.Close()
}

