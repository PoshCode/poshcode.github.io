function Encode-FileToBase64Block {
    param ( [ValidateScript({Test-Path $_ -PathType 'Leaf'})][string]$SourcePath ) 
    $leafName = (Get-Item $SourcePath).Name 
    Write-Output "`n`n`n# BEGIN base64 encoding of file ${leafName}`n<# BASE64ENCODE FILE: |${leafName}|"
    [system.convert]::ToBase64String((Get-Content $SourcePath -Encoding Byte), "InsertLineBreaks") 
    Write-Output "#> #END BASE64ENCODE FILE: |${leafName}|`n"
}


function Get-Base64BlockSection { 
    param ( 
            [ValidateScript({Test-Path $_ -PathType 'Leaf'})][string]$SourcePath,
            [switch]$List, 
            [string]$Indexfile
          )
    $encodedStartLines = $(get-content $SourcePath | select-string -Pattern "^<# BASE64ENCODE FILE: ")
    $outputFilenames   = $encodedStartLines | % { $_.Line.Split("|")[1]}
    if ($outputFilenames.Count -gt 0)
    {
        $metadataBlock = @{}
        foreach ($item in $outputFilenames)
        {
            $metadataBlock[$item] = @{}
            $metadataBlock[$item]["StartLine"] = $(get-content $SourcePath | select-string -Pattern "^<# BASE64ENCODE FILE: \|${item}\|").LineNumber
            $metadataBlock[$item]["EndLine"]   = $(get-content $SourcePath | select-string -Pattern "^#> #END BASE64ENCODE FILE: \|${item}\|").LineNumber
        }
        if ($List.IsPresent) { return $metadataBlock.Keys | sort }
        if (!$Indexfile) 
        { 
            Write-Host "ERROR: No index specified for the '-Indexfile' parameter" -ForegroundColor Red
            Write-Host "Available indexe(s) found are: $($outputFilenames -join " , ")`n`n"
            throw "No index specified"
        }
        else
        {
            $extractor = $metadataBlock.Keys | where { $_ -eq $Indexfile}
            if ($extractor)
            {
                (Get-Content $SourcePath)[$($metadataBlock[$extractor].StartLine) .. $($metadataBlock[$extractor].EndLine - 2 )]
            }
            else
            {
                Write-Host "ERROR: No Base64 Block index '$Indexfile' was found in file: $SourcePath`n`n" -ForegroundColor Red
                throw "Invalid index"
            }
        }
    }
    else
    {
        if ($List.IsPresent) {return $null}
        Write-Host "ERROR: No Base64 Block indexes detected in file: ${SourcePath}`n`n" -ForegroundColor Red
        throw "No block index detected"
    }
}

function Invoke-base64Extraction {
    param ( 
            [ValidateScript({Test-Path $_ -PathType 'Leaf'})][string]$SourcePath,
            [switch]$All, 
            [string]$Indexfile
          )
    if ($All.IsPresent) 
    {
        $fileList =  Get-Base64BlockSection -SourcePath $SourcePath -List
        $fileList | % { Invoke-base64Extraction -SourcePath $SourcePath -Indexfile $_ }
        return
    }
    Split-Path -Parent $MyInvocation.InvocationName
    $outputContentPath = Join-Path $defaultpath $Indexfile
    [system.convert]::FromBase64String((Get-Base64BlockSection -SourcePath $SourcePath -Indexfile $Indexfile)) | Set-Content $outputContentPath -Encoding Byte
}

## Create a payload:
#Encode-FileToBase64Block -SourcePath <<insert file with payloads here>>

## List all indexes in a payload
#Get-Base64BlockSection -SourcePath <<insert file with payloads here>> -List

## Example, to extract all base64 payload to files 
#Invoke-base64Extraction -SourcePath <<insert file with payloads here>> -All

## Example, Extract just one file from a multi-payload file
#Invoke-base64Extraction -SourcePath <<insert file with payloads here>> -Indexfile <<Index: name of the file>>

#bug: Invoke-base64Extraction need a destination path option probably :-)
