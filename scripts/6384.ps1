#Programmer Name: Nathan Estell
#Date: 8/14/2015
#Description: Displays a constant stream of numbers and spaces. This can cause patterns to form and can be mesmerizing :)

$max=10000 #This affects the balance between blank space and numbers. The higher this number, the more space the numbers take up.
$backGroundColor="Black"
$foreGroundColor="Green"

for (;;)
{
$r=(get-random -max $max).tostring()
#[int]$firstDigitRN=$randomNumber[0]
<# Possible way of implementing spaces with loop
for ($i=0;$i -lt $firstDigitRN;$i++)
{
" " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
#>
#Implementing the spaces with if statements

if ($r.startswith(0))
{
"" | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(1))
{
" " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(2))
{
"  " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(3))
{
"   " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(4))
{
"    " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(5))
{
"     " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(6))
{
"      " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(7))
{
"       " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(8))
{
"        " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
if ($r.startswith(9))
{
"         " | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}

$r | write-host -backgroundcolor $backGroundColor -foregroundcolor $foreGroundColor -NoNewLine
}
