
 #############################################################################################
#
# NAME: Find-Database.ps1
# AUTHOR: Rob Sewell http://sqldbawiththebeard.com
# DATE:22/07/2013
#
# COMMENTS: Load function for finding a database
# USAGE: Find-Database DBName
# ————————————————————————


Function Find-Database ([string]$Search)
{

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

# Pull a list of servers from a local text file

$servers = Get-Content 'c:\temp\sqlservers.txt'

#Create an empty Hash Table
$ht =@{}
$b = 0

				Write-Host "#################################"
				Write-Host "Searching for $DatabaseNameSearch "  
				Write-Host "#################################"  

#Convert Search to Lower Case
$DatabaseNameSearch = $search.ToLower()                                   

	#loop through each server and check database name against input
                    
foreach($server in $servers)
{
	$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
    
	foreach($database in $srv.Databases)
	{
    $databaseName = $database.Name.ToLower()

    	if($databaseName.Contains($DatabaseNameSearch))
        {

		$DatabaseNameResult = $database.name
        $Key = "$Server             $DatabaseNameResult"
        $ht.add($Key ,$b)
        $b = $b +1
        }

    }        
}


$Results = $ht.GetEnumerator() | Sort-Object Name|Select Name
$Resultscount = $ht.Count

if ($Resultscount -gt 0)
                        {

				        Write-Host "###############   I Found It!!  #################"
                                foreach($R in $Results)
                                    {
				                    Write-Host $R.Name 
                                    }
                        }

Else
{

    Write-Host "############    I am really sorry. I cannot find"  $DatabaseNameSearch  "Anywhere  ##################### "

}             

}

