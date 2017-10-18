function Get-Captures {
  #.Synopsis
  #   Takes data and a regex containing named captures, and outputs all of the resulting captures in one (or more) hashtable(s)
param( 
  [string]$text,
  [regex]$re,
  [switch]$NoGroup
)
  end {
    $matches = $re.Matches($data)
    $names = $re.GetGroupNames() | Where { $_ -ne 0 }
    $result = @{}
    foreach($match in $matches | where Success) {
      foreach($name in $names) {
        if($match.Groups[$name].Value) {
          if($NoGroup -or $result.ContainsKey($name)) {
            Write-Output $result
            $result = @{}
          }
          $result.$name = $match.Groups[$name].Value
        }
      }
    }
  }
}

function Get-Label {
  #.Synopsis
  #   Get labelled data using Regex
  #.Example
  #   openssl crl -in .\CSC3-2010.crl -inform der -text | Get-Label "Serial Number:" "Revocation Date:"
  param(
    # Text data that has labels with values in it
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [AllowEmptyString()]
    [string]$data,

    # The labels for the values (labels and values are presumed to be on their own lines)
    [Parameter(ValueFromRemainingArguments=$true, Position = 1)]
    [string[]]$labels = ("Serial Number:","Revocation Date:"),

    [switch]$NoGroup,

    [switch]$AsObjects
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

    write-verbose $re

    if($AsObjects) {
      foreach($hash in Get-Captures $data $re -NoGroup:$NoGroup) {
        New-Object PSObject -Property $hash
      }
    } else {
      Get-Captures $data $re -NoGroup:$NoGroup
    }
  }
}

