$a = New-Object psobject @{
    a = "Example"
    b = "Time"
}

$a | select @{
    name = "c"
    expression={$_.a + $_.b}
} | Out-File $home\desktop\Proof.txt
