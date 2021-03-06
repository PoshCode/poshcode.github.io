
Function New-localUserAccount {
param(
    [parameter(Mandatory=$true)]
    [string]$UserName,
    
    [parameter(Mandatory=$true)]
    [string]$Password,
    
    [parameter()]
    [string]$Description,
    
    [parameter()]
    [string]$FullName,
    
    [parameter()]
    [ValidateSet("Administrators","Users")]
    [string[]]$Groups,

    [parameter()]
    [switch]$PassDoesNotExpire, #adds Password does not expire

    [parameter()]
    [switch]$CannotChangePass, # Password cannot change

    [parameter()]
    [switch]$CreateDisabled,

    [parameter()]
    [switch]$PassMustChange
)

    $newUser = $Computer.Create("User", $UserName)
    $newUser.setpassword($Password)
    $newUser.SetInfo()

    $newUser = [adsi]"WinNT://$ComputerName/$UserName,User"
    $newUser.description = $Description
    $newUser.Fullname = $FullName

    $newUser.accountDisabled = $CreateDisabled.IsPresent
    $newUser.SetInfo()
    


    if ($PassDoesNotExpire){
        $newUser.psbase.InvokeSet("userFlags", ($newUser.userFlags[0] -BOR 65536)) # adds Password does not expire
        $newUser.psbase.CommitChanges()
    }
    if ($CannotChangePass){
        $newUser.psbase.InvokeSet("userFlags", ($newUser.userFlags[0] -BOR 64)) # adds Password cannot change
        $newUser.psbase.CommitChanges()
    }
    if ($PassMustChange){
        $newUser.passwordExpired = 1
        $newUser.SetInfo()
    }
    foreach ($group in $groups){
        $userGroup = $null
        $userGroup = [adsi]"WinNT://$ComputerName/$Group,group"
        $userGroup.add($newUser.path)
    }
}

