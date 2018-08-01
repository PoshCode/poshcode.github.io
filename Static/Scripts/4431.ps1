#############################################################################################
#
# NAME: Show-SQLUserLogins.ps1
# AUTHOR: Rob Sewell http://sqldbawiththebeard.com
# DATE:06/01/2013
#
# COMMENTS: Load function to Display a list of server, database and login for SQL servers listed 
# in sqlservers.txt file from a range of domains
#
# USAGE Show-SQLUserLogins DBAwithaBeard


Function Show-SQLUserLogins ($usr)
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
                Write-Host "SQL Servers, Databases and Logins for `n$logins displayed below " 
                Write-Host "################################# `n" 

	#loop through each server and each database and display usernames, servers and databases
       Write-Host " Server Logins`n"
         foreach($server in $servers)
{
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
    
    		foreach($login in $logins)
		{
    
    			if($srv.Logins.Contains($login))
			{

                Write-Host " $server , $login " 

			}
            
            else
            {

            }
         }
}
      Write-Host "`n#########################################"
     Write-Host "`n Database Logins`n"               
foreach($server in $servers)
{
	$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
    
	foreach($database in $srv.Databases)
	{
		foreach($login in $logins)
		{
			if($database.Users.Contains($login))
			{

                Write-Host " $server , $database , $login " 

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
