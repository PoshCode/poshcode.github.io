###  A first stab at the worlds simplest DSL:
###  How to generate XML from PowerShell, in code instead of string-substitution

$xlr8r = [type]::gettype("System.Management.Automation.TypeAccelerators")  
$xlinq = [Reflection.Assembly]::Load("System.Xml.Linq, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
$xlinq.GetTypes() | ? { $_.IsPublic -and !$_.IsSerializable -and $_.Name -ne "Extensions" } | % {
   $xlr8r::Add( $_.Name, $_.FullName )
}

function New-Xml {
   Param([String]$root)
   New-Object XDocument (New-Object XDeclaration "1.0","utf-8","no"),(
      New-Object XElement $(
         $root
         #  foreach($ns in $namespace){
            #  $name,$url = $ns -split ":",2
            #  New-Object XAttribute ([XNamespace]::Xmlns + $name),$url
         #  }
         while($args) {
            $attrib, $value, $args = $args
            if($attrib -is [ScriptBlock]) {
               &$attrib
            } elseif ( $value -is [ScriptBlock] -and "-Content".StartsWith($attrib)) {
               &$value
            } elseif ( $value -is [XNamespace]) {
               New-Object XAttribute ([XNamespace]::Xmlns + $attrib.TrimStart("-")),$value
            } else {
               New-Object XAttribute $attrib.TrimStart("-"), $value
            }
         }
      ))
}

function New-Element {
   Param([String]$tag)
   New-Object XElement $(
      $tag
      while($args) {
         $attrib, $value, $args = $args
         if($attrib -is [ScriptBlock]) {
            &$attrib
         } elseif ( $value -is [ScriptBlock] -and "-Content".StartsWith($attrib)) {
            &$value
         } elseif ( $value -is [XNamespace]) {
               New-Object XAttribute ([XNamespace]::Xmlns + $attrib.TrimStart("-")),$value
         } else {
            New-Object XAttribute $attrib.TrimStart("-"), $value
         }
      }
   )
}
Set-Alias xe New-Element


####################################################################################################
###### EXAMPLE SCRIPT: 
# [XNamespace]$dc = "http://purl.org/dc/elements/1.1"
#
# $xml = New-Xml rss -dc $dc -atom $atom -content $content -version "2.0" {
#    xe channel {
#       xe title {"Test RSS Feed"}
#       xe link {"http`://HuddledMasses.org"}
#       xe description {"An RSS Feed generated simply to demonstrate my XML DSL"}
#       xe ($dc + "language") {"en"}
#       xe ($dc + "creator") {"Jaykul@HuddledMasses.org"}
#       xe ($dc + "rights") {"Copyright 2009, CC-BY"}
#       xe ($dc + "date") {(Get-Date -f u) -replace " ","T"}
#       xe item {
#          xe title {"The First Item"}
#          xe link {"htt`p://huddledmasses.org/new-site-new-layout-lost-posts/"}
#          xe guid -isPermaLink true {"http`://huddledmasses.org/new-site-new-layout-lost-posts/"}
#          xe description {"Ema Lazarus' Poem"}
#          xe pubDate  {(Get-Date 10/31/2003 -f u) -replace " ","T"}
#       }
#    }
# }
#
# $xml.ToString()
#
####### OUTPUT: (NOTE: I added the space in the http: to paste it here -- those aren't in the output)
# <rss xmlns:dc="http ://purl.org/dc/elements/1.1" version="2.0">
#   <channel>
#     <title>Test RSS Feed</title>
#     <link>http ://HuddledMasses.org</link>
#     <description>An RSS Feed generated simply to demonstrate my XML DSL</description>
#     <dc:language>en</dc:language>
#     <dc:creator>Jaykul@HuddledMasses.org</dc:creator>
#     <dc:rights>Copyright 2009, CC-BY</dc:rights>
#     <dc:date>2009-07-26T00:50:08Z</dc:date>
#     <item>
#       <title>The First Item</title>
#       <link>http ://huddledmasses.org/new-site-new-layout-lost-posts/</link>
#       <guid isPermaLink="true">http ://huddledmasses.org/new-site-new-layout-lost-posts/</guid>
#       <description>Ema Lazarus' Poem</description>
#       <pubDate>2003-10-31T00:00:00Z</pubDate>
#     </item>
#   </channel>
# </rss>
