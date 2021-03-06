#.Synopsis
#  Download comic strip images
#.Description
#  Gets the latest comic from any of several different comic strips and downloads it to "My Pictures\Comix"
#.Parameter comic
#  The name of the comic to fetch: xkcd, dilbert, uf (user friendly)
#.Notes
# DEPEND-ON -Module HttpRest poshcode.org/787
# DEPEND-ON -Function Get-SpecialPath poshcode.org/858
#
PARAM([string[]]$comic = "xkcd") 
BEGIN {
   ## CHANGE THESE TWO LINES:
   Import-Module HttpRest  ## you can dot-source HttpRest instead, if you're on v1
   ## If you don't have Get-SpecialPath, just hard-code this
   $ComixPath = Join-Path $(Get-SpecialPath MyPictures) "Comix"
   MkDir $ComixPath -Force | Push-Location
   
   function Test-ComicPath {
      Param($comic)
      $comicFile = Join-Path $ComixPath $("{0} {1}" -f $comic, $(Get-Date -f "yyyy-MM-dd"))
      $comicFile
      if( Test-Path "$comicFile.*" ) {
         $(ls "$comicFile.*")
      } else {
         $false
      }
   }
}
PROCESS { 
   foreach($c in $comic) {
      $file,$exists = Test-ComicPath $c
      if($exists) { $exists; continue }
      $url = $null; 
      switch($c) {
         "dilbert" { 
            $doc = Invoke-Http GET "http`://dilbert.com/fast" -Wait
            ## Dilbert's Headers are broken (on purpose?)
            $doc.Headers["Content-Type"] = "text/html; charset=utf-8"
            $url = $doc | Receive-Http Text "//*[local-name()='img' and not(boolean(@alt))]/@src"
            if($url -notmatch "http`://dilbert.com/") {
               $url = "http`://dilbert.com/$url"
            }
         }
         "xkcd"    { 
            $url = Invoke-Http GET http`://xkcd.com/ | Receive-Http Text "//*[local-name()='img' and @title]/@src" 
         }
         "uf"      {
            $url = Invoke-Http GET http`://ars.userfriendly.org/cartoons/ @{id=$(Get-Date -f "yyyyMMdd")} | 
                   Receive-Http Text "//*[@alt='$(get-date -f 'S\trip \for MMM dd, yyyy')']/@src"
         }
      }
      if($url) {
         Invoke-Http GET $url | Receive-Http File "$file$([IO.Path]::GetExtension($url))"
      } else {
         Write-Warning "Couldn't get a url for $c"
      }
   }
}
END {
   Pop-Location
}
