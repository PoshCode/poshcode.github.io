<#
.SYNOPSIS
    Gets the encoding of a file
 
.EXAMPLE
    Get-FileEncoding.ps1 .\UnicodeScript.ps1
    
    BodyName          : unicodeFFFE
    EncodingName      : Unicode (Big-Endian)
    HeaderName        : unicodeFFFE
    WebName           : unicodeFFFE
    WindowsCodePage   : 1200
    IsBrowserDisplay  : False
    IsBrowserSave     : False
    IsMailNewsDisplay : False
    IsMailNewsSave    : False
    IsSingleByte      : False
    EncoderFallback   : System.Text.EncoderReplacementFallback
    DecoderFallback   : System.Text.DecoderReplacementFallback
    IsReadOnly        : True
    CodePage          : 1201

.PARAMETER Path
    Mandatory string parameter to specify the path to the file you wish to detect the encoding from

.PARAMETER DefaultEncoding
    Optional parameter to specify the default encoding, when no encoding can be detected
    
.NOTES
    From Windows PowerShell Cookbook (O'Reilly)
    by Lee Holmes (http://www.leeholmes.com/guide)
    Version: 1.3
    
    Version History:
    1.0: - 2011/??/??, Lee Holmes - initial release
    1.1: - 2017/01/13, Scripty Harry - changed statement "$Bytes = (Get-Content -encoding byte -readcount $EncodingLength $path)[0]"
                                      to "$Bytes = (Get-Content -encoding byte -readcount $EncodingLength -TotalCount $EncodingLength $path)"
                                      This prevents outrageous memory usage when reading large(ish) files
    1.2: - 2017/01/13, Scripty Harry - Encapsulated script into a function
    1.3: - 2017/01/13, Scripty Harry - Added DefaultEncoding parameter
#>
function Get-FileEncoding {
    param(
        ## The path of the file to get the encoding of.
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]$Path,
        
        [Parameter(Mandatory = $False)]
        [String]$DefaultEncoding = 'ASCII'
    )
     
    Set-StrictMode -Version Latest
     
    ## The hashtable used to store our mapping of encoding bytes to their
    ## name. For example, "255-254 = Unicode"
    $Encodings = @{}
     
    ## Find all of the encodings understood by the .NET Framework. For each,
    ## determine the bytes at the start of the file (the preamble) that the .NET
    ## Framework uses to identify that encoding.
    $EncodingMembers = [System.Text.Encoding] |
        Get-Member -Static -MemberType Property
     
    $EncodingMembers | Foreach-Object {
        $EncodingBytes = [System.Text.Encoding]::($_.Name).GetPreamble() -join '-'
        $Encodings[$EncodingBytes] = $_.Name
    }
     
    ## Find out the lengths of all of the preambles.
    $EncodingLengths = $Encodings.Keys | Where-Object { $_ } |
        Foreach-Object { ($_ -split "-").Count }
     
    ## Assume the encoding is as specified by the $DefaultEncoding parameter
    $Result = $DefaultEncoding
     
    ## Go through each of the possible preamble lengths, read that many
    ## bytes from the file, and then see if it matches one of the encodings
    ## we know about.
    foreach($EncodingLength in $EncodingLengths | Sort -Descending)
    {        
        $Bytes = (Get-Content -encoding byte -readcount $EncodingLength -TotalCount $EncodingLength $path)
        $Encoding = $Encodings[$Bytes -join '-']
     
        ## If we found an encoding that had the same preamble bytes,
        ## save that output and break.
        if($Encoding)
        {
            $Result = $Encoding
            break
        }
    }
     
    ## Finally, output the encoding.
    [System.Text.Encoding]::$Result
}
