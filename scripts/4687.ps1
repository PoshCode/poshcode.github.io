$string_indexes = [ordered]@{0=8;8=4;12=4;16=2;18=2;20=2;22=2;24=2;26=2;28=2;30=2}
$productcode = '1234567890123456789012345678901234'
foreach ($index in $string_indexes.GetEnumerator()) {
    $part = $productcode.Substring($index.Key,$index.Value).ToCharArray()
    [array]::Reverse($part)
    $part -join ''
}
