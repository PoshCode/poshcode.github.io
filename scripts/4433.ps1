﻿
#############################################################################################
#
# NAME: Show-SQLUserPermissions.ps1
# AUTHOR: Rob Sewell http://sqldbawiththebeard.com
# DATE:06/08/2013
#
# COMMENTS: Load function to Display the permissions a user has across the estate
# NOTE - Will not show permissions granted through AD Group Membership
# 
# USAGE Show-SQLUserPermissions DBAwithaBeard


Function Show-SQLUserPermissions ($usr)
{
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

# Suppress Error messages - They will be displayed at the end

$ErrorActionPreference = "SilentlyContinue"
#cls

# Pull a list of servers from a local text file

$servers = Get-Content 'c:\temp\sqlservers.txt'

# Create an array for the username and each domain slash username

$logins = @("DOMAIN1\$usr","DOMAIN2\$usr", "DOMAIN3\$usr" , "$usr")

				Write-Host "#################################" 
                Write-Host "Logins for `n $logins displayed below" 
                Write-Host "################################# `n" 

	#loop through each server and each database and display usernames, servers and databases
       Write-Host " Server Logins"
         foreach($server in $servers)
{
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
    
    		foreach($login in $logins)
		{
    
    			if($srv.Logins.Contains($login))
			{

                                    Write-Host "`n $server , $login " 
                                            foreach ($Role in $Srv.Roles)
                                {
                                    $RoleMembers = $Role.EnumServerRoleMembers()
                                    
                                        if($RoleMembers -contains $login)
                                        {
                                        Write-Host " $login is a member of $Role on $Server"
                                        }
                                }

			}
            
            else
            {

            }
         }
}
      Write-Host "`n#########################################"
     Write-Host "`n Database Logins"               
foreach($server in $servers)
{
	$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
    
	foreach($database in $srv.Databases)
	{
		foreach($login in $logins)
		{
			if($database.Users.Contains($login))
			{
                                       Write-Host "`n $server , $database , $login " 
                        foreach($role in $Database.Roles)
                                {
                                    $RoleMembers = $Role.EnumMembers()
                                    
                                        if($RoleMembers -contains $login)
                                        {
                                        Write-Host " $login is a member of $Role Role on $Database on $Server"
                                        }
                                }
                    

			}
                else
                    {
                        continue
                    }   
           
		}
	}
    }
   Write-Host "`n#########################################"
   Write-Host "Finished - If there are no logins displayed above then no logins were found!"    
   Write-Host "#########################################" 





}

