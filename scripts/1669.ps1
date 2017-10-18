# Manage_ASP_NET_Providers.ps1
# by Chistian Glessner
# http://iLoveSharePoint.com

# have to be initaized. If you want to change the app config you have to restart PowerShell
param($appConfigPath=$(throw "-appConfigPath is mandatory"))
{
    # App config path have to be set before loading System.Web.dll
    [System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $path )
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web") # posh 2.0: Add-Type -Assembly "System.Web"
}

function global:Get-MembershipProvider($providerName=$null)
{    
    if($providerName -eq $null)
    {
        return [System.Web.Security.Membership]::Provider
    }
    else
    {
        return [System.Web.Security.Membership]::Providers[$providerName]
    } 
}

function global:Get-RoleProvider($providerName=$null)
{     
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
    if($providerName -eq $null)
    {
        return [System.Web.Profile.ProfileManager]::Provider
    }
    else
    {
        return [System.Web.Profile.ProfileManager]::Providers[$providerName]
    } 
}
