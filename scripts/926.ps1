## This script serves three purposes:
## 1) You can look up whether a name is masculine or feminine
##    -- even for foreign names.
## 2) It demonstrates the use of the HttpRest functions
## 3) It demonstrates memory-caching:
##    how to write a SCRIPT ...
##    that becomes a FUNCTION the first time you use it.


param([string]$name)          ## note that this matches the params of the function
   
function global:get-gender {  ## note the "global:" pushes the function to the global scope
   param([string]$name)       ## note that this matches the params above!
   
   if($name.Length -lt 2) { throw "You need at least two letters in the name" }
   $name = "$($name[0])".ToUpper()  + $name.SubString(1).ToLower()

   ## All of this is actually a one-liner. You can delete all the carriage returns,
   ## and stick it all where the elipsis is: "Joel","Wendy" | % { ... } 
   switch(
      Invoke-Http GET "http://www.babynameaddicts.com/cgi-bin/search.pl" @{
         gender="ALL";searchfield="Names";origins="ALL";searchtype="matching";searchtext=$name
      } | Receive-Http Text "//font[b/font/text()='$name']/@color" )
   { 
      "fucshia" { "Femenine" }
      "#088dd0" { "Masculine" } 
   }
}

get-gender $name              ## All three sets of parameters match....

## Note that this technique works with Advanced functions as well, 
## But making it work IN the pipeline is way more work :)

