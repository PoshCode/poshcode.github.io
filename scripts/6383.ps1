function Draw
{
param
(
$text=@"
q   
 q  
  q 
   q
"@
)
$CharArray=$text.tochararray()
foreach ($character in $CharArray)
{
if ($character -match "\S" )
{
write-host " " -BackgroundColor "Green" -NoNewLine
#"Character"
}
if ($character -match "[^\S\r\n]")
{
write-host " " -BackgroundColor "Black" -NoNewLine
#"Space"
}
if ($character -match "\n" )
{
write-host "" 
#"New Line"
}
}
}
