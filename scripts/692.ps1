## DekiWiki Module 1.5
#require -version 2.0
## Depends on the HttpRest script-module:
##              http :// huddledmasses.org/using-rest-apis-from-powershell-with-the-dream-sdk/ 
####################################################################################################
## The first of many script cmdlets for working with DekiWiki, based on the HttpREST module
##
## For documentation of the DekiWiki REST API:
## http :// wiki.developer.mindtouch.com/MindTouch_Deki/API_Reference
####################################################################################################
## USAGE:
##   Add-Module DekiWiki
##   Set-DekiUrl http`://powershell.wik.is
##   ...
## ## For usage of each cmdlet, see the comments above each individual function ## ## ## ## ## ## ##
####################################################################################################
## History:
## v 1.5 Rewrite with the "Dream" specific code extracted to the HttpRest module
## v 1.2 Remove-DekiFile
## v 1.0 Set-DekiCredential, Get-DekiContent, Set-DekiContent, New-DekiContent, Set-DekiFile
## 
$hr = Add-Module HttpRest -Passthru
Add-Module "$PSScriptRoot\Utilities.ps1"

$url = "http://powershell.wik.is"
$api = "$url/@api/deki"

#New-Alias Set-DekiCredential Set-HttpCredential -EA "SilentlyContinue"
#New-Alias Set-DekiUrl Set-HttpDefaultUrl -EA "SilentlyContinue"

FUNCTION Set-DekiUrl {
   PARAM ([uri]$baseUri=$(Read-Host "Please enter the base Uri for your RESTful web-service"))
   Set-HttpDefaultUrl $baseUri
}

FUNCTION Set-DekiCredential {
   PARAM($Credential=$(Get-Credential -Title "Http Authentication Request - $($global:url.Host)" `
                                      -Message "Your login for $($global:url.Host)" `
                                      -Domain $global:url.Host ))
   Set-HttpCredential $Credential
}

New-Alias e2 Encode-Twice -EA "SilentlyContinue"


Add-Type '
public class ModuleInfo {
   public string Name;
   public string[] Author;
   public string CompanyName;
   public string[] Copyright;
   public string[] Description;
   public System.Version ModuleVersion;
   public string[] RequiredAssemblies;
   public string[] Dependencies;
   public System.Guid GUID = System.Guid.NewGuid();
   public string[] PowerShellVersion;
   public string[] ModulesToProcess;
   public System.Version CLRVersion;
   public string[] FormatsToProcess;
   public string[] TypesToProcess;
   public string[] OtherItems;
   public string ModuleFile;
}
' -EA "SilentlyContinue"

# Retrieve a sitemap of all the pages in a wiki, 
# OR Retrieve all the subpages of a page as a sitemap
# Added by Mark E. Schill
CMDLET Get-DekiSiteMap {
PARAM( 
	[Parameter(Position=0, Mandatory=$false)]
	[string]
	$StartPage
,
	[Parameter(Position=1, Mandatory=$false)]
	[ValidateSet("xml","html","google")]
	[string]
	$Format = "xml"
)
   if($StartPage) {
      Invoke-Http GET "pages/=$(e2 $StartPage)/tree" @{"format"=$format} | Receive-Http -Out Xml
   } else {
      Invoke-Http GET "pages" @{"format"=$format} | Receive-Http -Out Xml
   }
}


# Get the contents of a page from a DekiWiki
# Note that by default you retrieve the "view" (rendered) markup
# If you want to see it before the extensions run, you should specify at least -mode viewnoexecute
# If you want to see the source so you can make changes, be sure to specify -mode edit
CMDLET Get-DekiContent {
PARAM(
   [Parameter(Position=0, Mandatory=$true)]
   [string]
   $pageName
, 
   [Parameter(Position=1, Mandatory=$false)]
   [int]
   $section
, 
   [Parameter(Position=5, Mandatory=$false)]
   [ValidateSet("edit", "raw", "view", "viewnoexecute")]
   [string]
   $mode="view"
)
   Invoke-Http "GET" "pages/=$(e2 $pageName)/contents" @{mode=$mode;section=$section} | Receive-Http -Out Xml
}

# Get-DekiFile will LIST all files if called with just a PageName
# Otherwise, fileName can be a single fileName, or wildcards
# To download all the attachments on a page, try:
# Get-DekiFile PageName | Get-DekiFile 
CMDLET Get-DekiFile {
PARAM(
   [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
   [string]
   $pageName
,
   [Parameter(Position=1, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
   [string]
   $fileName
,
   [Parameter(Position=2, Mandatory=$false)]
   [string]
   $destination
)
PROCESS {
   ## Remember, we can get both on the pipeline, so ...
   $files = Invoke-Http "GET" "pages/=$(e2 $pageName)/files" | Receive-Http Xml //file
   
   Write-Verbose "Fetching $($fileName) from the $($files.Count) in $pageName"
   if(!$fileName) {
      ## Add a PageName property, because then you can pipe the output back to Get-DekiFile after filtering...
      write-output $files | Add-Member NoteProperty PageName $pageName -passthru
   } else {
      ## Using -like means $fileName allows globbing
      foreach($file in $($files | where { $_.filename -like $fileName } )) {
         Invoke-Http "GET" "pages/=$(e2 $pageName)/files/=$(e2 $file.filename)" | Receive-Http File $(Get-FileName $file.filename $destination)
      }
   }
}
}

# Set the contents of a DekiWiki page
# Note that you can pass the content as an XML document, plain text, or a filename...
CMDLET Set-DekiContent {
PARAM(
   [Parameter(Position=0, Mandatory=$true)]
   [string]
   $pageName
, 
   [Parameter(Position=1, Mandatory=$true, 
                          ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [string]
   $content
, 
   [Parameter(Position=2, Mandatory=$false)]
   $section
,
   [switch]$new
,
   [switch]$append
)
   $with = @{"edittime"=$(Get-UtcTime "yyyyMMddhhmmss")}
   
   if($new) {
      $with.abort = "exists"
   }
   if($append) {
      $with.section = "0"
   } elseif($section) {
      $with.section = $section
   }

   $result = Invoke-Http POST "pages/=$(e2 $pageName)/contents" -With $with -Content $content -Auth $true -Wait
   if($result.IsSuccessful) {
      return "$url/$($result | Receive-Http Text //edit/page/path)"
   } else {
      return $result
   }
}

# Same as Set-DekiContent, except this one crashes if the page already exists.
# This is technically the only safe way to create new pages without fear of conflicts...
CMDLET New-DekiContent {
PARAM(
   [Parameter(Position=0, Mandatory=$true)]
   [string]$pageName
, 
   [Parameter(Position=1, Mandatory=$true, 
              ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   [string]
   $content
)
PROCESS {
   Set-DekiContent $pageName $content -new
}
}

# Add a new attachment (or a new version of an existing attachment)
# You can use wildcards, and specify arrays.  But you could also include descriptions
# USAGE:
## Set-DekiFile Path/PageName *.ps1,*.psm1
## Set-DekiFile Path/PageName @{"Neat.jpg"="A really cool screenshot";"Source.zip"="The source code"}
## Set-DekiFile Path/PageName Something.png
## ls *.png | Set-DekiFile Path/PageName
CMDLET Set-DekiFile {
param(
   [Parameter(Position=0, Mandatory=$true)]
   [string]$pageName
, 
   [Parameter(Position=1, Mandatory=$true,
              ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("FullName")]
   $Files
)
   # Two ways to specify files: 1) hashtable: file = "description" 1) array: file, file, file
   $hasDescriptions = $false;
   if($files -is [Hashtable]) {
      $hasDescriptions = $true;
      $fileNames = $files.Keys
   } else {
      $fileNames = $files
   }
   
   foreach($fileName in $fileNames) {
      foreach($file in (gci $fileName)) {
         $with = @{}
         if($hasDescriptions) {
            $With.description = $files[$fileName]
         }

         $result = Http-Invoke PUT "pages/=$(e2 $pageName)/files/=$($file.Name)" $With $file.FullName -Wait
         if($result.IsSuccessful) {
            return ($result | Receive-Http Text //file/href)
         } else {
            return $result.Response
         }
      }
   }
}

## Move a page from one place to another (leaving an "alias" placeholder)

CMDLET Move-DekiContent {
PARAM(
   [Parameter(Position=0, Mandatory=$true)]
   [string]
   $pageName
, 
   [Parameter(Position=1, Mandatory=$true)]
   [string]
   $newPageName
)
   $with = @{"to"="$newPageName"}
   
   $result = Invoke-Http POST "pages/=$(e2 $pageName)/move" -With $with -Auth $true -Wait
   if($result.IsSuccessful) {
      return "$url/$($result | Receive-Http Text '//page[1]/path' )"
   } else {
      return $result
   }
}

CMDLET New-DekiAlias {
PARAM(
   [Parameter(Position=0, Mandatory=$true)]
   [string]
   $pageName
, 
   [Parameter(Position=1, Mandatory=$true)]
   [string]
   $Alias
)
  
   $result = Invoke-Http POST "pages/=$(e2 $pageName)/move" @{"to"="$Alias"} -Auth $true -Wait
   if($result.IsSuccessful) {
      $aliasPage = "$url/$($result | Receive-Http Text '//page[1]/path' )"
      $result = Invoke-Http POST "pages/=$(e2 $Alias)/move" @{"to"="$pageName"} -Auth $true -Wait
      if($result.IsSuccessful) {
         return $aliasPage
      } else {
         return $result
      }
   } else {
      return $result
   }
}

# Delete a page from a dekiwiki, with an option to RECURSIVELY delete all child pages.
# NOTE: if you delete a page that has children, and don't recurse, the contents are removed
#       and then replaced with template text, because they can't go away completely
# NOTE: if you delete a page, it is actually put in the archive
# TODO: add a -Force parameter to allow them to be permanently deleted from the archive
CMDLET Remove-DekiContent {
PARAM(
   [Parameter(Position=0, Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$pageName
,
   [Parameter(Position=2, Mandatory=$false)][switch]$recurse
)

   Http-Invoke DELETE "pages/=$(e2 $pageName)" @{recursive=$($recurse.ToBool())}
   if($result.IsSuccessful) {
      return "DELETED $url/$PageName"
   } else {
      return $result.Response
   }
}

# Delete a file attachment from a dekiwiki page
# You can use wildcards, and specify arrays:
## USAGE:
## Remove-DekiFile Path/PageName *.ps1,*.psm1
## Remove-DekiFile Path/PageName Something.png
## ls *.png | Remove-DekiFile Path/PageName
CMDLET Remove-DekiFile {
PARAM(
   [Parameter(Position=0, Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$pageName
,
   [Parameter(Position=1, Mandatory=$true,
              ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("Name")]
   $fileNames
)
   $files = Invoke-Http GET "pages/=$(e2 $pageName)/files" | Receive-Http Text //file/filename
   foreach($fileName in $fileNames) {
      foreach($file in $($files -like $fileName)) {
         $path = "pages/=$(e2 $pageName)/files/=$(e2 $file)"
         Write-Host $path -fore cyan
         $result = Invoke-Http DELETE $path -Auth $true -Wait
      
         if($result.IsSuccessful) {
            "DELETED: $api/$path"
         } else {
            $result.Response
         }
      }
   }
}

Export-ModuleMember Set-DekiCredential, Set-DekiUrl, 
                    Get-HtmlHelp, Get-DekiFile, Get-DekiSiteMap, Get-DekiContent, 
                    Set-DekiContent, New-DekiContent,
                    Move-DekiContent, New-DekiAlias,
                    Remove-DekiContent, Remove-DekiFile,
                    Set-DekiFile

