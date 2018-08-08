Param($file,$headers)
# Check for Input and fill $data
if($input){$data = @();$input | foreach-Object{$data += $_}}

# Check for File and Test the Path
if($file)
{
    if(Test-Path $file)
    {
        # Check for Headers... if none use import-csv
        if(!$headers)
        {
            import-Csv $data
            return
        }
        else
        {
            $data = Get-Content $file
        }
    }
    else{Write-Host "Invalid File Passed";return $false}
}
       
# Creating Object
foreach($entry in $data)
{
    $values = $entry.Split(",")
    if($values.Count -gt $headers.Count)
    {
        Write-Host "Value Count [$($values.Count)] and Headers [$($Headers.Count)] do not match"
        return $false
    }
    $myobj = "" | Select-Object -prop $headers
    $i = 0
    foreach($value in $values)
    {
        $header = $headers[$i]
        $myobj.$header = $value
        $i++
    }
    $myobj
}
