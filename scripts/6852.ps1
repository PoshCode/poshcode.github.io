# lists
$devList = New-Object System.Collections.ArrayList
$prodList = New-Object System.Collections.ArrayList

Try {
    $hostList = gc $hostsToCheckFile -ErrorAction Stop
}
Catch {
    #$ErrorMessage = $_.Exception.Message
    #$FailedItem = $_.Exception.ItemName
    echo "ERROR: Could not open $hostsToCheckFile..."
    Break
}
    

foreach ($line in $hostList) {
    #echo "$line"

    if ($line -match "^nzp") {
        echo "Adding $line to prod list..."
        $prodList.Add($line)
    }
    elseif ($line -match "^nz") {
        echo "Adding $line to dev list..."
        $devList.Add($line)
    }
    else {
        echo "Cannot process $line..."
    }
}

# create a new remote session on the NSR server
$s = New-PSSession -ComputerName $devServer #-Credential $devCreds

# $devList array needs to be wrapped in an array as ArgumentList expects an array of arguments. See http://stackoverflow.com/questions/17577705/passing-array-to-another-script-with-invoke-command.
Invoke-Command -Session $s -ArgumentList (,$devList) -ScriptBlock {
    param($devList)

    #$devList

    foreach ($client in $devList) {
        echo "Checking client $client..."
        $out = (mminfo -q "savetime>=24 hours ago,name=/,client=$client" -ot -r "savetime,client,name,sumsize,level")
        echo $out
    }
}


# There's a limit of 5 remote PS sessions per user
echo "Removing PS session..."
Remove-PSSession $s
