#############################################################################################
#
# NAME: Add-WindowsAccountToSQLRole.ps1
# AUTHOR: Rob Sewell http://sqldbawithabeard.com
# DATE:11/09/2013
#
# COMMENTS: Load function to create a windows user and add them to a server role
#
# USAGE: Add-WindowsAccountToSQLRole FADE2BLACK 'FADE2BLACK\Test' dbcreator
#        Add-WindowsAccountToSQLRole FADE2BLACK 'FADE2BLACK\Test' public

Function Add-WindowsAccountToSQLRole ([String]$Server, [String] $User, [String]$Role)
{

$Svr = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server

# Check if Role entered Correctly
    if($svr.Roles.name -notcontains $Role)
        {
        Write-Host " $Role is not a valid Role on $Server"
        }

    else
        {
#Check if User already exists
    		if($svr.Logins.Contains($User))
			    {
                $SqlUser = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login $Server, $User
                $LoginName = $SQLUser.Name
                $svrole = $svr.Roles | where {$_.Name -eq $Role}
                $svrole.AddMember("$LoginName")
                }

            else
                {
                $SqlUser = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login $Server, $User
                $SqlUser.LoginType = 'WindowsUser'
                $SqlUser.Create()
                $LoginName = $SQLUser.Name
                $svrole = $svr.Roles | where {$_.Name -eq $Role}
                $svrole.AddMember("$LoginName")
                }
        }

}

