Function New-FileShare {
#this function returns $True is the share is successfully created
    Param([string]$computername=$env:computername,
          [string]$path=$(Throw "You must enter a complete path relative to the remote computer."),
          [string]$share=$(Throw "You must enter the name of the new share."),
          [string]$comment,
          [int]$connections
          )
          
    $FILE_SHARE = 0
 
    if (! $connections) {
        #if no connection number specifed set to $Null so
        #share will be created with maximum number of connections
        [void]$connections = $NULL
        }
    #uncomment this next line for debugging
#     Write-Host ("Creating share {0} for {1} on {2} ({3})" -f $share,$path,$computername,$comment) -fore Green
    
    [wmiclass]$wmishare="\\$computername\root\cimv2:win32_share"
    
    $return=$wmishare.Create($path,$share,$FILE_SHARE,$connections,$comment)
    
    Switch ($return.returnvalue) {
        0 {$rvalue = "Success"}
        2 {$rvalue = "Access Denied"}     
        8 {$rvalue = "Unknown Failure"}     
        9 {$rvalue = "Invalid Name"}     
        10 {$rvalue = "Invalid Level"}     
        21 {$rvalue = "Invalid Parameter"}     
        22 {$rvalue = "Duplicate Share"}     
        23 {$rvalue = "Redirected Path"}     
        24 {$rvalue = "Unknown Device or Directory"}
        25 {$rvalue = "Net Name Not Found"}
    }
    
    if ($return.returnvalue -ne 0) {
        Write-Warning ("Failed to create share {0} for {1} on {2}. Error: {3}" -f $share,$path,$computername,$rvalue) 
        return $False
    }
    else {
        return $True
    }
}
