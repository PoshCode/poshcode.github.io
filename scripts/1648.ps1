@@ # UpdateADPC.ps1, to be run outside of Poshboard
function Get-DomainComputerAccounts
{

# Use Directory Services object to attach to the domain
$searcher = new-object DirectoryServices.DirectorySearcher([ADSI]"")
#Leaving the ADSI statement empty = attach to your root domain 

# Filter down to computer accounts
$searcher.filter = "(&(objectClass=computer))"

# Cache the results
$searcher.CacheResults = $true
$searcher.SearchScope = “Subtree”
$searcher.PageSize = 1000

# Find anything you can that matches the definition of being a computer object
$accounts = $searcher.FindAll()

# Check to make sure we found some accounts
if($accounts.Count -gt 0)
{
foreach($account in $accounts)
	{
# Property that contains the last password change in long integer format
$pwdlastset = $account.Properties["pwdlastset"];

# Convert the long integer to normal DateTime format
$lastchange = [datetime]::FromFileTimeUTC($pwdlastset[0]);

# Determine the timespan between the two dates
$datediff = new-TimeSpan $lastchange $(Get-Date);

# Create an output object for table formatting
$obj = new-Object PSObject;

# Add member properties with their name and value pair
$obj | Add-Member NoteProperty ComputerName($account.Properties["name"][0]);
$obj | Add-Member NoteProperty LastPasswordChange($lastchange);
$obj | Add-Member NoteProperty DaysSinceChange($datediff.Days);

# Write the output to the screen
Write-Output $obj;
}
}
}

Get-DomainComputerAccounts | Where-Object {$_.DaysSinceChange -gt 30} | sort dayssincechange | Export-CSV C:\temp\AD.csv -NoType


@@ #Poshboard Code
$dash = new-pbdashboard -Name "Object Password Age Method" -MaxColumns 1
$exclude = "UnixServer01","NetworkAppliance","Server01","Server02","Server03"
add-pbitem $dash (import-csv c:\temp\AD.csv | where {$exclude -notcontains $_.ComputerName} | out-pbdatagrid ComputerName,DaysSinceChange,LastPasswordChange -name "Computer accounts older than 30 days" -fontsize 10 -showgrouppane 0)
$dash

