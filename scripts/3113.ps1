# Reverse filename sequence v 0.9
# Author: Sean Wendt
# 
# This script will rename a sequenced set of files in a directory.
# For example, you have foobar01.jpg, foobar02.jpg, foobar03.jpg 
# -- it will reverse the order, so the last file is now 01, the second to last 02, etc..
# 
# Limitations: 	-You cannot use the same filename prefix, i.e. foobar must change to foobars.
# 				-It's hardcoded to only support 5 digit numbers right now.
#				-Similarly, it will only support a file sequence with up to 5 digits.
# This is the first script I've written, I know it's not great! ;)
# Help to make it better would be appreciated. Thanks.
#

$file_extension = Read-Host "Enter file extension, i.e. .jpg or .txt"
$file_prefix = Read-Host "Enter file prefix, i.e. entering foobar will rename files to foobar001.ext, foobar002.ext, etc.."
$files =  Get-ChildItem | ?{ $_.PSIsContainer -ne "True"} # Creates array of files in current directory, ignores folders
$idx = 0 # Sets index value (0 = filenames start at foobar00000.jpg, modify to 1 to start at foobar00001.jpg)

for ($ctr=$files.count; $ctr -gt 0 ; --$ctr)
{
	if (($idx -ge 0) -and ($idx -le 9))
		{
		Rename-Item -path $files[$ctr-1].name -newname ($file_prefix + '00000' + $idx++ + $file_extension)
		}
	elseif (($idx -ge 10) -and ($idx -le 99))
		{
		Rename-Item -path $files[$ctr-1].name -newname ($file_prefix + '0000' + $idx++ + $file_extension)
		}
	elseif (($idx -ge 100) -and ($idx -le 999))
		{
		Rename-Item -path $files[$ctr-1].name -newname ($file_prefix + '000' + $idx++ + $file_extension)
		}
	elseif (($idx -ge 1000) -and ($idx -le 9999))
		{
		Rename-Item -path $files[$ctr-1].name -newname ($file_prefix + '00' + $idx++ + $file_extension)
		}
	elseif (($idx -ge 10000) -and ($idx -le 99999))
		{
		Rename-Item -path $files[$ctr-1].name -newname ($file_prefix + '0' + $idx++ + $file_extension)
		}
	$idx #prints the index # it just completed
}


