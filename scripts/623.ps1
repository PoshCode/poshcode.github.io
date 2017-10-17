function get-gender {
   param([string]$name)
   
   if($name.Length -lt 2) { throw "You need at least two letters in the name" }
   $name = "$($name[0])".ToUpper()  + $name.SubString(1).ToLower()

   $page = get-web "http://www.babynameaddicts.com/cgi-bin/search.pl?gender=ALL;searchfield=Names;origins=ALL;searchtype=matching;searchtext=$name"
   switch( $page.SelectNodes( "//table//font[ b/descendant::font[contains(text(),'$name')]]" ) | select -expand color ) {
      "fucshia" { "Female" }
      "#088dd0" { "Male" }
   }
}
