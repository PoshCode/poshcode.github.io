## Get-HtmlHelp - by Joel Bennett
## version 3.2
#####################################################################
## Cool Example, using ShowUI:
##    Import-Module HtmlHelp
##    Import-Module ShowUI -Vers 1.4
##    function Show-Help { [CmdletBinding()]param([String]$Name)  
##       Window { WebBrowser -Name wb } -On_Loaded { 
##          $wb.NavigateToString((Get-HtmlHelp $Name))
##          $this.Title = "Get-Help $Name"
##       } -Show
##    }
##    Show-Help Get-Help
## 
#####################################################################
## Import System.Web in order to use HtmlEncode functionality
Add-Type -Assembly System.Web

function ConvertTo-Dictionary([hashtable]$ht) {
   $kvd = new-object "System.Collections.Generic.Dictionary``2[[System.String],[System.String]]"
   foreach($kv in $ht.GetEnumerator()) { $kvd.Add($kv.Key,$kv.Value) }
   return $kvd
}


function htmlEncode {
   param([Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)][String]$Text)
   process{ [System.Web.HttpUtility]::HtmlEncode($Text) }
}

function trim {
   param([Parameter(ValueFromPipeline=$true,Mandatory=$true)][String]$string)
   process{ $string.Trim() }
}

function trimUrl{
   param([Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)][String]$Text)
   process{ [System.Web.HttpUtility]::UrlEncode($Text).Trim() }
}

function trimHtml{
   param([Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)][String]$Text)
   process{ [System.Web.HttpUtility]::HtmlEncode($Text).Trim() }
}

function HHSplit {
   param(
      $Separator="\s*\r?\n",
      [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
      [String]$inputObject
   )
   process{ 
      foreach($item in [regex]::Split($inputObject,$Separator)) {
         $item.Trim() | Where {$_.Length} 
      }
   }
}

function HHjoin {
   param(
      [Parameter(Position=0)]
      $Separator=$ofs,
      
      [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
      [String[]]
      $inputObject
   )
   begin   { [string[]]$array = $inputObject }
   process { $array += $inputObject }
   end     { 
      if($array.Length -gt 1) { 
         [string]::Join($Separator,$array)
      } else { 
         $array
      }
   }
}
function Out-HtmlTag {
   param([Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)][String]$Text, $Tag="p")
   process{
      $html = $Text | out-string -width ([int]::MaxValue) | HHSplit | trimHtml | HHjoin "</$tag>`n<$tag>"
      $html = $html -replace '(\S+)(http://.*?)([\s\p{P}](?:\s|$))','<a href="$2">$1</a>$3'
      "<$tag>$html</$tag>"
   }
}
function Out-HtmlList {
   param([Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)][String]$Text)
   process{
      "<li>$($Text | out-string -width ([int]::MaxValue) | HHSplit | trimHtml | HHjoin "</li>`n<li>")</li>"
   }
}
function Out-HtmlDefList {
   param(
      [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]$Node,
      [String[]]$Term,
      [String[]]$Definition
   )
   # begin { "<dl>"}
   process{
      $tx = $Node
      foreach($t in $Term) { $tx = $tx.$t; Write-Verbose "${t}: $tx" }
      $dx = $Node
      foreach($d in $Definition) { $dx = $dx.$d; Write-Verbose "${t}: $dx"  }
      
      if($tx) { $tx = $tx | trimHtml } else { return }
      if($dx) { $dx = $dx | trimHtml } else { $dx = "" }
      "<dt>{0}</dt><dd>{1}</dd>" -f $tx, $dx
   }
   # end { "</dl>"}
}
function Out-HtmlBr {
   param([Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)][String]$Text)
   process{
      $Text | out-string -width ([int]::MaxValue) | HHSplit | trimHtml | HHjoin "<br />"
   }
}

## Utility Functions 
function Get-UtcTime {
   Param($Format="")
   [DateTime]::Now.ToUniversalTime().ToString($Format)
}

function Encode-Twice {
   param([Parameter(ValueFromPipeline=$true,Mandatory=$true)][String]$string)
   process {
      [System.Web.HttpUtility]::UrlEncode( [System.Web.HttpUtility]::UrlEncode( $string ) )
   }
}


## Get-HtmlHelp - A Helper function for generating help:
## Usage:  Get-HtmlHelp Get-*
function Get-HtmlHelp {
#.Synopsis
#  Generates HTML for help
#.Description
#  Takes the output of Get-Help for cmdlets for functions and outputs in HTML form with some basic styling.
#
#.Example
#  C:\PS>Get-HtmlHelp Get-HtmlHelp > Get-HtmlHelp.html
#  Generates this help into the specified html file.
#.Example
#  C:\PS>Get-HtmlHelp *-ScheduledJob -OutputFolder .
#  Generates HTML help for all of the *-ScheduledJob commands and saves them as .html files in the current folder.
#.Example
#  C:\PS>Get-Command -Module HtmlHelp | Get-HtmlHelp | ForEach { Set-Content $_.Name $_ }
#  Generates HTML help into files taking advantage of the "Name" property on the output to determine the file name.
#.Example
#  C:\PS>Import-Module HtmlHelp, ShowUI
#  C:\PS>function Show-Help { [CmdletBinding()]param([String]$Name)  
#  >> Window { WebBrowser -Name wb } -On_Loaded { 
#  >>    $wb.NavigateToString((Get-HtmlHelp $Name))
#  >>    $this.Title = "Get-Help $Name"
#  >>   } -Show
#  >> }
#  C:\PS>Show-Help Get-Help
#
#  Creates a function Show-Help to show the HTML rendered help in ShowUI without saving it to file.
[CmdletBinding()]
param(
   # The command(s) you want to generate help for.
   [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
   [String[]]$Name, 
   # The base Url for links to related commands.
   [string]$BaseUrl = "http://technet.microsoft.com/en-us/library/",
   # If set, the output goes to files in the folder.
   [String]$OutputFolder
)
process {
   foreach($help in $Name | Get-Command -EA "SilentlyContinue" | Get-Help -Full) {
      $output = $help | Convert-HelpToHtml $baseUrl | 
                        Add-Member -Name Name -Type NoteProperty -Value $(Split-Path $help.Name -Leaf) -Passthru
      if($OutputFolder) {
         Set-Content $(Join-Path $OutputFolder "$($output.Name).html") $output
      } else {
         $Output
      }
   }
}
}

function textile {
param([string]$text)

$text -replace '(?<=\r\n\r\n|^)\*\s(.*)(?=\r\n)',"<ul>`r`n<li>`$1</li>"                     <# start of a list      #>`
      -replace '(?<=\r\n)\*\s+((?:.|\r\n(?![\*\r]))+)(?=\r\n\r\n|\r\n\*|$)',"<li>`$1</li>"  <# middle of a list     #>`
      -replace '</li>(?=\r\n\r\n|$)',"</li>`r`n</ul>"                                       <# end of the list      #>`
      -replace '(?<=\r\n\r\n|^)([^\n]*)(?=\r\n\r\n|$)',"<p>`r`n`$1`r`n</p>"                 <# regular paragraphs   #>`
      -replace '(?<=\r\n\r\n)([^\r\n]*\s+[^\r\n]*)\r\n(-+)(?=\r\n\r\n)',"<h3>`$1</h3>"      <# headers              #>`
      -replace '(?<=[^\r\n>])(\r\n)(?=[^\r\n]+)',"<br />`$1"                                <# remaining linebreaks #>`
      -replace "  "," &nbsp;"  # Because the content is originally for get-help, preserve whitespace
}

function Convert-ParameterHelp {
param([Parameter(ValueFromPipeline=$true,Mandatory=$true)]$ParameterItem) 
process {
   $name = $( 
      if($ParameterItem.position -ne "named") {
         "[-<strong>{0}</strong>]" -f $ParameterItem.name
      } else { 
         "-<strong>{0}</strong>" -f $ParameterItem.name
      }
   )

   if($ParameterItem.required -eq "false") {
      "<nobr>[{0} {1}]</nobr>" -f $name, $ParameterItem.parameterValue
   } else {
      "<nobr>{0} {1}</nobr>" -f $name, $ParameterItem.parameterValue
   }
}
}

function Convert-SyntaxItem {
param([Parameter(ValueFromPipeline=$true,Mandatory=$true)]$SyntaxItem) 
process {
   "<li>{0} {1}</li>" -f $SyntaxItem.name, $($SyntaxItem.parameter | Convert-ParameterHelp | join " ")
}
}

function Convert-HelpToHtml {
param(
[string]$baseUrl,

[Parameter(ValueFromPipeline=$true)]
$Help
)
PROCESS {
      #  throw "Can only process -Full view help output"

      # Name isn't needed, since this is going as the body, but ...
      # $data = "<html><head><title>$(trimHtml($help.Name))</title></head><body>";
      # $data += "<h1>$(trimHtml($help.Name))</h1>"
$data = @"
<html>
<head>
<title>$(trimHtml($help.Name))</title>
<style type="text/css">
   h1, h2, h3, h4, h5, h6 { color: #369 }
   ul.syntax {
      list-style: none outside;
      font-size: .9em;
      font-family: Consolas, "DejaVu Sans Mono", "Lucida Console", monospace;
   }
   ul.syntax li {
      margin: 3px 0px;
   }
   table.parameters th {
      text-align: left;
   }
</style>
</head>
<body>
<h1 id='$(trimHtml($help.Name))'>$(trimHtml($help.Name))</h1>
"@
      # Synopsis
      $data += "`n<h2>Synopsis</h2>`n$($help.Synopsis | Out-HtmlTag -Tag p)"
      
      # Syntax
      $data += "`n<h2 class='syntax'>Syntax</h2>`n<ul class='syntax'>$($help.Syntax.syntaxItem | Convert-SyntaxItem)</ul>"
   
      # Related Commands
      if($help.relatedLinks.navigationLink) {
         $data += "`n<h2>Related Commands</h2>`n"
         foreach ($relatedLink in $help.relatedLinks.navigationLink) {
            $uri = ""
            if( $relatedLink.uri -ne "" ) {
               $text = $uri = $relatedLink.uri
               if($relatedLink.linkText) { $text = $relatedLink.linkText }
            } elseif($relatedLink.linkText) {
               $text = $relatedLink.linkText
               $cmd = get-command $text -EA "SilentlyContinue"
               if($cmd -and $cmd.PSSnapin) {
                  $uri = "$baseUrl/$(trimUrl $cmd.PSSnapin.Name)/$(trimUrl $text)"
               } elseif($cmd -and $cmd.Module) {
                  $uri = "$baseUrl/$(trimUrl $cmd.Module.Name)/$(trimUrl $text)"
               } else {
                  $uri = "$baseUrl/$(trimUrl $text)"
               }
            }
            $data += "<a href='$uri'>$(trimHtml $text)</a><br>"
         }
      }
   
      # Detailed Description
      if($help.Description) {
         $data += "`n<h2>Detailed Description</h2>`n$($help.Description | Out-HtmlTag -Tag p)"
      }
   
      # Parameters
      $data += "`n<h2>Parameters</h2>"
      foreach($param in $help.parameters.parameter) {
         $data += "`n<h4>-$(trimHtml($param.Name)) [&lt;$(trimHtml($param.type.name))&gt;]</h4>"
         if($Param.Description) {
            $data += $param.Description | Out-HtmlTag -Tag p
         }
         $data += "`n<table class='parameters'>"
         $data += "`n<tr><th>Required? &nbsp;</th><td> $(trimHtml($param.Required))</td></tr>"
         $data += "`n<tr><th>Position? &nbsp;</th><td> $(trimHtml($param.Position))</td></tr>"
         if($param.DefaultValue) {
            $data += "`n<tr><th>Default value? &nbsp;</th><td> $(trimHtml($param.defaultValue))</td></tr>"
         }
         $data += "`n<tr><th>Accept pipeline input? &nbsp;</th><td> $(trimHtml($param.pipelineInput))</td></tr>"
         if($param.globbing) {
            $data += "`n<tr><th>Accept wildcard characters? &nbsp;</th><td> $(trimHtml($param.globbing))</td></tr>"
         }
         $data += "</table>`n`n"
      }
   
      # Input Type
      if($help.inputTypes -and $help.inputTypes.inputType) {
         $data += "`n<h3>Input Type</h3>`n<dl class='input'>$(
            $help.inputTypes.inputType | Out-HtmlDefList -Term type, name -Definition description
         )</dl>"
      }
      
      # Output Type
      if($help.returnValues -and $help.returnValues.returnValue ) {
         $data += "`n<h3>Output Type</h3>`n<dl class='output'>$(
            $help.returnValues.returnValue | Out-HtmlDefList -Term type, name -Definition description
         )</dl>"
      }
      
      # Notes
      if($help.alertSet -and $help.alertSet.alert) {
         $data += "`n<h2>Notes</h2>`n$($help.alertSet.alert | Out-HtmlTag -Tag p)"
      }
   
      # Examples
      if($help.Examples.example -and $help.Examples.example.Length) {
         $data += "<h2>Examples</h2>"
         
         foreach($example in $help.Examples.example){
            if($example.title) {
               $data += "<h4>$(trimHtml($example.title.trim(' -')))</h4>`n"
            }
            $data += "<code><strong>C:\PS&gt;</strong>&nbsp;$(($example.code | Out-HtmlBr) -replace "<br />C:\\PS&gt;","<br />`n<strong>C:\PS&gt;</strong>&nbsp;")</code>"
            $data += "<p>$($example.remarks | out-string -width ([int]::MaxValue) | Out-HtmlTag -Tag p)</p>"
         }
      }
      $data += "`n</body></html>"

      write-output $data
}}

Export-ModuleMember Get-HtmlHelp

