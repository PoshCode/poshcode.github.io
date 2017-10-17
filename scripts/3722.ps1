Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue

# Location of the CSV file created. 
$fileLocation = "C:\temp\logon.csv"

# Get the Current Date 
$CURRENTDATE=GET-DATE

# Number of days to check
$COMPAREDATE = $CURRENTDATE.AddDays(-30)

# Your AD Domain
$server = "ad.domain.com"

Get-QADUser -Service $server -SizeLimit 0 |where {$_.LastLogon -gt $COMPAREDATE }| select lastlogon,lastname,firstname,logonname,whencreated,description |Export-Csv $fileLocation


