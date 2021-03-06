#Author: Tozzi June 2012
#OriginalAuthor: Ant B 2012
#Purpose: Batch feed recipients to MailChimp

$ie = new-object -com "InternetExplorer.Application"

# Vars for building the URL
$apikey = "api-key-from-mailchimp"
$listid = "list-id-from-mailchimp"

# Important is to use correct MailChimp data centre. In this case us5, yours might be different
$URL = "https://us5.api.mailchimp.com/1.3/?output=xml&method=listBatchSubscribe&apikey=$apikey"
$URLOpts = "&id=$($listid)&double_optin=False&Update_existing=True"
$Header = "FirstName","Lastname","PrimarySmtpAddress"
$GroupName = "distribution-group-name"

# Get members of the group
$DGMembers = Get-DistributionGroupMember $GroupName | select FirstName, Lastname, PrimarySmtpAddress

# Copy the array contents to a CSV for comparison on the next run, we'll use it to look for removals
if (test-path "C:\submitted.csv") {
	Clear-Content submitted.csv
}
$DGMembers | select PrimarySmtpAddress | export-csv C:\submitted.csv

# Check for the CSV created above and dump it to an array for comparison
if (test-path "C:\submitted.csv") {
	$list = Import-CSV -delimiter "," -Path C:\submitted.csv -Header $Header
}
$Removals = compare-object $DGMembers $list | Where {$_.SideIndicator -eq "=>"}

# Loop through the array of group members and submit to the MailChimp API
ForEach ($ObjItem in $DGMembers)
{
	$batch = "&batch[0][EMAIL]=$($ObjItem.PrimarySmtpAddress)&batch[0][FNAME]=$($ObjItem.FirstName)&batch[0][LNAME]=$($ObjItem.Lastname)"
	$MailOpts = "&batch[0][EMAIL_TYPE]html"
	$FURL = $URL + $batch + $MailOpts + $URLOpts
	Write-Host $FURL
	$ie.navigate($FURL)
	Start-Sleep -MilliSeconds 300
}
