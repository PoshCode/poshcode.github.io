function Export-PowerSite {
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
        $language,

        [Parameter(ValueFromPipelineByPropertyName)]
        $code
    )
    process {
        if($language -eq "posh") {
            $language = "powershell"
        }

        $extension = switch($language) {
            "asp"        { ".asp" }
            "bash"       { ".sh"  }
            "cpp"        { ".cpp" }
            "csharp"     { ".cs"  }
            "javascript" { ".js"  }
            "powershell" { ".ps1" }
            "text"       { ".txt" }
            "vbnet"      { ".vb"  }
            "xml"        { ".xml" }
            default      { ".txt" }
        }

        # Work around PowerShell's insistence on BOMs
        function Write-AllLines {
            param($Path, $Content)
            $null = New-Item $Path -Type File -Force
            [IO.File]::WriteAllLines((Convert-Path $Path), $content)
        }

        Write-AllLines "Pages\scripts\$id.md" @"
---
pid:            $id
author:         $author
title:          $title
date:           $date
tags:           $language
file:           Static\scripts\$id$extension
$(if($parent){   "parent:         $($parent -join ',')"})
$(if($children){ "children:       $($children -join ',')"})
---

### [download $title$extension](/scripts/$id$extension)$(if($parent -ne 0) { " - [parent](/scripts/$parent.md)" })$( if($children){  " - children: $($(foreach($child in $children) { "[$child](/scripts/$child.md)" }) -join ', ')" })

$description

``````$language
$code
``````
"@
        Write-Progress (Resolve-Path "Pages\scripts\$id.md")

        Write-AllLines "Static\scripts\$id$extension" $code
        Write-Progress (Resolve-Path "Static\scripts\$id$extension")
    }
}

Push-Location $PSScriptRoot
Write-Warning "This dump contains some malware samples which will trigger your AV"
Get-Item $PSScriptRoot\Static\scripts, $PSScriptRoot\Pages\scripts -ErrorAction SilentlyContinue |
    Remove-Item -Confirm -Recurse
$null = New-Item $PSScriptRoot\Static\scripts -Type Directory
$null = New-Item $PSScriptRoot\Pages\scripts -Type Directory

Import-Csv $PSScriptRoot\PoshCodeData.csv | Export-PowerSite