function Get-Label {
    #.Synopsis
    #   Get labelled data using Regex
    #.Example
    #   openssl.exe crl -in .\CSC3-2010.crl -inform der -text | Get-Label "Serial Number:" "Revocation Date:"
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [string]$data,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$labels = ("Serial Number:","Revocation Date:")
    )
    begin {
        [string[]]$FullData = $data
    }
    process {
        [string[]]$FullData += $data
    }

    end {
        $data = $FullData -join "`n"

        $names = $labels -replace "\s+" -replace "\W"

        $re = "(?m)" + (@(
            for($l=0; $l -lt $labels.Count; $l++) {
                $label = $labels[$l]
                $name = $names[$l]
                "$label\s*(?<$name>.*)\s*`$"
            }) -join "|")
        write-host $re
        $re = [Regex]$re

        $matches = $re.Matches($data)    
        foreach($match in $matches | where Success) {
            foreach($name in $names) {
                if($match.Groups[$name].Value) {
                    @{$name = $match.Groups[$name].Value}
                }
            }
        }
    }
}

