<#

.NOTES
    AUTHOR: Sunny Chakraborty(sunnyc7@gmail.com)
	WEBSITE: http://tekout.wordpress.com
    VERSION: 0.1
	CREATED: 17th April, 2012
	LASTEDIT: 17th April, 2012
	Requires: PowerShell v2 or better

.CHANGELOG
4/17/2012 Try passing powershell objects to PROTO API and pass the variables to .JS file
	Pass other system variables and check if text to speech can translate double or a double-to-char conversion is required.
4/18/2012 Changed get-diskusage to gwmi -class win32_logicaldisk

.SYNOPSIS
    Make a phone call from Powershell.
	
.DESCRIPTION
	The script demonstrates how you can collect state-data in powershell and pass it as an argument to a REST API call and alert a System Admin.
	For this example, TROPO REST API's were used. (www.tropo.com)
	The phone-number will receive a Call with the following text To speech
		Please check the server $this. 
		The percent Free Space on C Drive is $inDecimals.

	This is a proof of concept. V 0.1
	There are numerous areas of improvement. 
	
.IMPORTANT
	Please create a new account and setup your application in tropo. Its free for dev use. http://www.tropo.com
	Copy and replace the TOKEN in your application with the TOKEN below to initiate a call.
	
.OTHER

JAVASCRIPT (Hosted on Tropo)

TropoTest.js
call('+' + numToCall , {
  timeout:30,
  callerID:'19172688401',
      onAnswer: function() {
      	say("Houston ! We have a problem ");
	say("Please check the server" + sourceServer );
	say("The percent Free Space on C Drive is" + freeCDisk );
	say("Goodbye.");
	log("Call logged Successfully");
  },
  onTimeout: function() {
      	log("Call timed out");
  },
  onCallFailure: function() {
      	log("Call could not be completed as dialed");
  }
});

#>

# Proto API section. Please replace protoToken with your own Application Token, 
# I am posting my API token here so that someone can download and run the script by editing just the cell # field.
$baseUrl = "https://api.tropo.com/1.0/sessions?action=create&"

# Modify these variables.
$protoToken = "10b0026696a79f448eb21d8dbc69d78acf12e2f1f62f291feecec8f2b8d1eac76da63d91dd317061a5a9eeb0"
#US 10 Digit only for now. For Example 17327911234,19177911234  
# Calls to Outside US are not allowed during the dev trials on Tropo.
# You will receive a call from this number - 19172688401. That's the callerID
$myCell = '11234567890'

# Functions
#4.18.12 -- Previous versoin used Get-DiskUsage and was erroring out if the cmldet is not installed.
#modified it to use GWMI
Function get-FreeDiskPercentForC {
$disk = gwmi -class "win32_LogicalDisk"
$free = $disk[0].FreeSpace / $disk[0].Size
$freeDiskCPercent = [System.Math]::Round($free, 2)
$freeDiskCPercent
}

# Get some more parameters here.
$sourceServer =hostname
$cDisk = get-FreeDiskPercentForC

# Concatenate and form the Proto API string. I am sure someone can figure out a better way to do this than just adding.
$callThis = $baseUrl+ 'token=' + $protoToken + '&numToCall=' + $myCell + '&sourceServer=' + $sourceServer + '&freeCDisk=' + $cDisk

# Call the Proto API
# I could have tested this with Invoke-RestMethod, but I didn't see the point. I am not receiving any data from the URL.
$newClient = new-object System.Net.WebClient
$newClient.DownloadString($callThis)
