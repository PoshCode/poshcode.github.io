    # From: Brandon Shell
    # Purpose: To Reset Local User Account
    # Example:
    # -- To Reset user Password
    # PS> Add-User -user Jsmith -password H!Th3r3 -server myserver1
    # With Creds
    # PS> Add-User -user Jsmith -password H!Th3r3 -server myserver1 -luser adminGuy -lPassword HateClearText!
    #################################################################
    Param([string]$user,[string]$password,[string]$server,[switch]$auth)
    
    If(!($server)){$server = get-content env:COMPUTERNAME}
    $dePath = "WinNT://$server/$user,user"
    if($auth)
    {
        $lUser = Read-Host "Enter UserName"
        $lPassword = Read-Host "Enter Password"
        $myuser = new-Object System.DirectoryServices.DirectoryEntry($dePath,$lUser,$lPassword)
    }
    else
    {
        $myuser = new-Object System.DirectoryServices.DirectoryEntry($dePath)
    }
    $myuser.psbase.invoke("SetPassword",$password)
    $myuser.psbase.CommitChanges()
    if($?){Write-Host "Reset Password Successful!"}else{Write-Host "Reset Failed"}

