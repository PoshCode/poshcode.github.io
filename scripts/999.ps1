function Get-ChildItem2 ($path)
{
    # path can either be absolut or relative, I only tried filesystem
    # perhaps to named Get-ChildItemsRecursive
    $root = gi $path
    $PathLength = $root.FullName.length
    # it would be nice if Split-Path could do the trick, I didn't grok it 
    gci $path -rec | % {
    Add-Member -InputObject $_ -MemberType NoteProperty -Name RelativePath -Value $_.FullName.substring($PathLength+1)
    $_
    }
}

# Try for example:
# Get-ChildItem2 $pshome | % {$_.RelativePath }
# Now generate demo data

cd f:
md tmp
md tmp\gcir\dir1
md tmp\gcir\dir2
"file1" > tmp\gcir\dir1\file1.txt
"file2" > tmp\gcir\dir1\file2.txt
copy-Item tmp\gcir\dir1\file1.txt tmp\gcir\dir2\file1.txt # both file1 have same length and LastWriteTime 
"file2changed" > tmp\gcir\dir2\file2.txt  # different length forced by different contents

# now we get pathnames relative to the starting path
Get-ChildItem2 tmp | % {$_.RelativePath }
<#
gcir
gcir\dir1
gcir\dir2
gcir\dir1\file1.txt
gcir\dir1\file2.txt
gcir\dir2\file1.txt
gcir\dir2\file2.txt
#>


# and it is easy to compare two trees of files
Compare-Object (Get-ChildItem2 tmp\gcir\dir1) (Get-ChildItem2 tmp\gcir\dir2) -prop RelativePath, LastWriteTime, Length -includeEqual
<#
RelativePath        LastWriteTime                    Length SideIndicator      
------------        -------------                    ------ -------------      
file1.txt           05.04.2009 10:45:03                  16 ==                 
file2.txt           05.04.2009 10:45:03                  30 =>                 
file2.txt           05.04.2009 10:45:03                  16 <=                 
#>

# well we look only for the different files
Compare-Object (Get-ChildItem2 tmp\gcir\dir1) (Get-ChildItem2 tmp\gcir\dir2) -prop RelativePath, LastWriteTime, Length

# add some fiddeling to the newest file only
$last = $null
Compare-Object (Get-ChildItem2 tmp\gcir\dir1) (Get-ChildItem2 tmp\gcir\dir2) -prop RelativePath, LastWriteTime, Length |
Sort RelativePath, LastWriteTime -desc | % {
if ($last -ne $_.RelativePath)
{ $_ }
$last = $_.RelativePath
} | sort RelativePath

<#
RelativePath        LastWriteTime                    Length SideIndicator      
------------        -------------                    ------ -------------      
file2.txt           05.04.2009 10:45:03                  30 =>                 
#>
