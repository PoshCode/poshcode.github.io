#Valid characters
$CharsString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789!@#$%^&*()-=_+[]/\{}|:;'`",.<>?``~"

#Testing
a' -match "[$([regex]::escape($CharsString))]"
> False
