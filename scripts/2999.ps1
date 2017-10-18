cd c:\windows\temp\common

foreach($File in get-childitem | where-object{($_.Extension -ieq '.PS1') -or ($_.Extension -ieq '.PSM1')})
{
    $FileName = $File.Name
    $TempFile = "$($File.Name).ASCII"

@@    get-content $FileName | out-file $TempFile -Encoding ASCII 

    remove-item $FileName

    rename-item $TempFile $FileName
}

