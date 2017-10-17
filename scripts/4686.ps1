Function GetTOCStats {
    $TOCsummary = get-content -path "$env:USERPROFILE\desktop\testReport.log"
    [array]::Reverse($TOCsummary)
    [int] $i = "0"
    [string] $strTotal =  "Total"
    [string] $strCopied = "Copied"
    $TOCsummary | % {
        if (Select-String -Pattern "Total    Copied   Skipped  Mismatch    FAILED    Extras" -InputObject $_ -Quiet) {
            $start = $TOCsummary[$i].IndexOf($strTotal) + $strTotal.length
            $end = $TOCsummary[$i].IndexOf($strCopied) + $strCopied.length
            $copiedColumnwidth = ($end - $start)
            $TOCfileCount = $TOCsummary[($i-2)].substring($start,$copiedcolumnwidth).trim()
            $TOCsize = $TOCsummary[($i-3)].substring($start,$copiedcolumnwidth).trim()
            write-host "# of files: $TOCfileCount"
            write-host "Copy size: $TOCsize"
            }
            $i++
    }
}

GetTOCStats


