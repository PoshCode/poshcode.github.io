# Manage_ASP_NET_Providers.ps1
# by Chistian Glessner
# http://iLoveSharePoint.com

# If you want to change the app config you have to restart PowerShell
param($appConfigPath=$null)

# App config path have to be set before loading System.Web.dll
[System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $appConfigPath )
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web") 

function global:Get-MembershipProvider($providerName=$null, [switch]$all)
{    
	if($all)
	{
		return [System.Web.Security.Membership]::Providers
	}
	
    if($providerName -eq $null)
    {
        return [System.Web.Security.Membership]::Provider
    }
    else
    {
        return [System.Web.Security.Membership]::Providers[$providerName]
    } 
}

function global:Add-MembershipUser($login=$(throw "-login is required"), $password=$(throw "$password is required"), $mail=$(throw "-mail is required"),$question, $answer, $approved=$true)
{
	$provider = $input | select -First 1
	
	if($provider -isnot [System.Web.Security.MembershipProvider])
	{
		$provider = Get-MembershipProvider
	}

	$status = 0
	$provider.CreateUser($login, $password, $mail, $question, $answer, $approved, $null, [ref]$status)
	return [System.Web.Security.MembershipCreateStatus]$status			
}

function global:Get-MembershipUser($identifier, $maxResult=100)
{
	$provider = $input | select -First 1

	if($provider -isnot [System.Web.Security.MembershipProvider])
	{
		$provider = Get-MembershipProvider
	}
			
	if($identifier -ne $null)
	{		
		$name = $provider.GetUserNameByEmail($identifier)
		
		if($name -ne $null){$identifier = $name}		
		
		return $provider.GetUser($identifier,$false)
	}

	$totalUsers = 0
	$users = $provider.GetAllUsers(0,$maxResult,[ref]$totalUsers) 
	
	$users
	
	if($totalUsers -gt $maxResult)
	{
		throw "-maxResult limit exceeded"
	}			
}

function global:Reset-MembershipUserPassword($identifier=$(throw "-identifier is required"), $questionAnswer)
{
	$provider = $input | select -First 1

	if($provider -isnot [System.Web.Security.MembershipProvider])
	{
		$provider = Get-MembershipProvider
	}
	
	$name = $provider.GetUserNameByEmail($identifier)
		
	if($name -ne $null){$identifier = $name}	
	
	return $provider.ResetPassword($identifier, $questionAnswer)
}

function global:Get-RoleProvider($providerName=$null, [switch]$all)
{     
	if($all)
	{
		return [System.Web.Security.Roles]::Providers
	}

    if($providerName -eq $null)
    {
        return [System.Web.Security.Roles]::Provider
    }
    else
    {
        return [System.Web.Security.Roles]::Providers[$providerName]
    } 
}

function global:Get-ProfileProvider($providerName=$null)
{     
	if($all)
	{
		return [System.Web.Security.ProfileManager]::Providers
	}

    if($providerName -eq $null)
    {
        return [System.Web.Profile.ProfileManager]::Provider
    }
    else
    {
        return [System.Web.Profile.ProfileManager]::Providers[$providerName]
    } 
}
