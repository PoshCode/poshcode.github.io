"$([Char[]](65..90) | % {if (!(Test-Path ($_ + ':'))) {$_}})"

<#
Output sample:
A B G H I J K L M N O P Q R S T U V W X Y
#>
