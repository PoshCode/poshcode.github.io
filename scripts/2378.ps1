$mykey = "xxx"
$newkey = "yyy"
$OFS = ""

cd C:\Users\kagami\Downloads
ls | % {
    if ($_.name -match "^\[rutracker\.org\].*\.torrent") {
        $file = $_.name
        $data = cat -en byte -LiteralPath $file
        $data2 = ([string][char[]]$data) -replace "ann\?uk=$mykey", "ann?uk=$newkey"
        sc -en byte -value ([byte[]][char[]]$data2) -LiteralPath "_torrent/$file"
        rm -LiteralPath $file
    }
}
