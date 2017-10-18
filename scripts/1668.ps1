# Manage_ASP_NET_Providers.ps1
# by Chistian Glessner
# http://iLoveSharePoint.com

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web") # posh 2.0: Add-Type -Assembly "System.Web"

function global:Set-AppConfigPath($path=$(throw "-path is mandatory"))
{
    [System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $path )
}

function global:Get-MembershipProvider($appConfigPath=$null, $providerName=$null)
{ 
    if($appConfigPath -ne $null)
    {
        Set-WebConfigPath $webConfigPath
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

function global:Get-RoleProvider($appConfigPath=$null, $providerName=$null)
{     
    if($appConfigPath -ne $null)
    {
        Set-WebConfigPath $webConfigPath
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

function global:Get-ProfileProvider($appConfigPath=$null, $providerName=$null)
{     
    if($appConfigPath -ne $null)
    {
        Set-WebConfigPath $webConfigPath
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
