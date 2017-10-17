## Language.ps1 includes Resolve-Language, Get-English, and Resolve-Anagram
###################################################################################################
## Some language functions, including a language guessing script using a web form 
## Xerox Research Center Europe (www.xrce.xerox.com) which may not always be available, 
## and the translation functions from Google Translate (google.com/translate_t).
###################################################################################################
## This script uses "ConvertFrom-Html" which is a cmdlet I wrote to parse html as xml
## I've put that cmdlet out there in several places ...
#requires -pssnapin Huddled.HtmlSnapin
###################################################################################################
## @Author: Joel Bennnett
## @Usage:
##    Resolve-Language "Mon tutoriel avancÃ© sur PowerShell"   
##          will return "French"
##    Get-English "Mon tutoriel avancÃ© sur PowerShell" "French"
##          will translate it to "My advanced tutorial on PowerShell"
##    Get-English "Mi tutorial avanzado para PowerShell"
##          will guess the language and then translate it 
##  
## Remember that this uses web sites for it's work which are NOT meant to be publically 
## queryable web services, and shouldn't be abused -- the Xerox site in particular could
## be removed if they get a huge spike, because there is a commercial implementation
###################################################################################################
## Requires System.Web for UrlEncode
[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null


###################################################################################################
## Deteremine the language of a snippet of text (5 words minimum for best results)
function Resolve-Language([string]$text) {
   return (ConvertFrom-HTML (Post-HTTP  "http://www.xrce.xerox.com/cgi-bin/mltt/LanguageGuesser" (
                                 "Text="+[System.Web.HttpUtility]::UrlEncode($text)))
   ).SelectSingleNode("//font")."#text".Trim()
}

###################################################################################################
## Translate text to english ...
## This is obviously reworkable as a general translation tool
## But I don't have much use for that, since I only speak Spanish, English, and code
function Get-English([string]$text,[string]$FromLanguage) {
   if(!$FromLanguage) {
      $FromLanguage = Resolve-Language $text
   }
   
   switch($FromLanguage) {
      "Arabic"       { $text = "langpair=ar|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Chinese"      { $text = "langpair=zh|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Dutch"        { $text = "langpair=nl|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "French"       { $text = "langpair=fr|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "German"       { $text = "langpair=de|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Greek"        { $text = "langpair=el|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Italian"      { $text = "langpair=it|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Japanese"     { $text = "langpair=ja|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Korean"       { $text = "langpair=ko|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Portuguese"   { $text = "langpair=pt|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Russian"      { $text = "langpair=ru|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      "Spanish"      { $text = "langpair=es|en&text=" + [System.Web.HttpUtility]::UrlEncode($text) }
      default { return "Sorry, but I can't translate $language" }
   }                                             
   return (ConvertFrom-HTML (Post-HTTP "http://www.google.com/translate_t" $text)).SelectSingleNode("//div[@id='result_box']")."#text".Trim()
}

###################################################################################################
## Silly anagram spoiler
[regex]$anagram = "^Unscramble ... (.*)$"
function Resolve-Anagram($anagram) {
   ((Post-HTTP "http://www.easypeasy.com/anagrams/results.php" "name=$anagram").Split("`n") |
    select-string "res 1" ) -replace ".*res 1.*value=""\s*([^""]*)\s*"".*",'$1'
}

###################################################################################################
## Post as a web-form to do fake submissions
function Post-HTTP($url,$bytes) {
   $request = [System.Net.WebRequest]::Create($url)
   # $bytes = [Text.Encoding]::UTF8.GetBytes( $bytes )
   $request.ContentType = "application/x-www-form-urlencoded"
   $request.ContentLength = $bytes.Length
   $request.Method = "POST"
   $rq = new-object IO.StreamWriter $request.GetRequestStream()
   $rq.Write($bytes)#,0,$bytes.Length)
   $rq.Flush()
   $rq.Close()
   $response = $request.GetResponse()
   $reader = new-object IO.StreamReader $response.GetResponseStream(),[Text.Encoding]::UTF8
   return $reader.ReadToEnd()
}
