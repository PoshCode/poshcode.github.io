function Export-PoshCodeGithub {
[CmdletBinding()]
param(
    [Parameter(ValueFromPipelineByPropertyName)]
    $parent,

    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias("child")]
    $children,

    [Parameter(ValueFromPipelineByPropertyName)]
    [alias("pid")]
    $id,

    [Parameter(ValueFromPipelineByPropertyName)]
    [alias("poster")]
    $author,

    [Parameter(ValueFromPipelineByPropertyName)]
    $title,

    [Parameter(ValueFromPipelineByPropertyName)]
    $date,

    [Parameter(ValueFromPipelineByPropertyName)]
    $description,

    [Parameter(ValueFromPipelineByPropertyName)]
    [alias("format")]
    $Language,

    [Parameter(ValueFromPipelineByPropertyName)]
    $code
)
process {

$extension = switch($Language) {
    "asp"        { ".asp" }
    "bash"       { ".sh" }
    "cpp"        { ".cpp" }
    "csharp"     { ".cs" }
    "javascript" { ".js" }
    "posh"       { ".ps1" }
    "text"       { ".txt" }
    "vbnet"      { ".vb" }
    "xml"        { ".xml" }
}


@"
---
pid:            $id
parent:         $parent
children:       $($children -join ',')
poster:         $author
title:          $title
date:           $date
description:    $description
format:         $Language
---

# $title

### [download]($id$extension) $(if($parent -ne 0) { "[parent]($parent.md)" }) $(foreach($child in $children) { "[$child]($child.md)" })

$description

``````$language
$code
``````
"@ | Out-File "$id.md"

$code | Out-File "$id$extension"

}
}