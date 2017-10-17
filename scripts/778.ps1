Function New-Script
{
$strName = $env:username
$date = get-date -format d
$name = Read-Host "Filename"
if ($name -eq "") { $name="NewTemplate" }
$email = Read-Host "eMail Address"
if ($email -eq "") { $email="youremail@yourhost.com" }
$file = New-Item -type file "$name.ps1" -force
$template=@"
###########################################################################"
#
# NAME: $name.ps1
#
# AUTHOR: $strName
# EMAIL: $email
#
# COMMENT:
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 $date - Initial release
#
###########################################################################"
"@ | out-file $file
ii $file
}
