function Get-MessagesToMailboxforSpecificMonth {

<#
.SYNOPSIS
    Determine the messages sent to mailbox since first day of month till the last day of month. Export the list with specific columns to .csv file 
 
.DESCRIPTION
    Get-MessagesToITSforSpecificMonth is a function that returns the list with details of message sent to a mailbox during a month
 
.PARAMETER Month
    The month to extract details of messages. The default is the previous month.

.PARAMETER Mailbox
    The mailbox to extract details of messages. There is no default, it is mandatory parameter.

.EXAMPLE
    Get-MessagesToITSforSpecificMonth -Mailbox am@contoso.com -Server nice-server.corp.contoso.com
 
.EXAMPLE
     Get-MessagesToITSforSpecificMonth -Month October -Mailbox am@contoso.com
 
.INPUTS
    Month, Mailbox
 
.OUTPUTS
    File in the path where script is called
 
.NOTES
    Author:  Andrei Moraru
    Website: http://develam.com
    Twitter: andrei.moraru.n@gmail.com
#>

param (
[string]$Month,
[ValidateNotNullorEmpty()][string]$Mailbox
)

Add-PSSnapin -Name Microsoft.Exchange.Management.Powershell.SnapIn

# Variable definition
# =========
# get the current year
$year = Get-Date -Format "yyyy"

# define array with months of the year with 31 days
$arrMonths31days = "January","March","May","July","August","October","December"

# define array with months of year with 30 days
$arrMonths30days = "April","June","September","November"

# define error message for incorrect specified month
$outOfMonth = "Incorrect name of month, please specify English month name, i.e. January, February, March, etc."

# define error message for inexistent mailbox
$noMailbox = "Mailbox $Mailbox doesn't exist in Exchange organization"

# =========
# =========

# Validation
# =========
# validate if the mailbox exists
if(-not ($Mailbox))
    {
    Write-Host -ForegroundColor Red "You must supply a value for -Mailbox"
    return
    } elseif(Get-Mailbox $Mailbox -ErrorAction SilentlyContinue)
        {}
    else {
    Write-Host -ForegroundColor Red $noMailbox
    return
    }
    

# in case no month is specified, then default to previous month (i.e., if now is November then the value for month is defaulted to October)
if (-Not $Month) {$Month = (Get-Date).AddMonths(-1).ToString('MMMM')}


## Logic section
# = 
# Set the value of $endMonth variable, dependent on $Month value. There are three cases:
# Months with 31 days - listed in $arrMonth31Days
# Months with 30 days - listed in $arrMonth30Days
# February with 28 days
# incorrect value specified

# check if $Month value is a month with 31 days and if true, set the value of $endMonth to 31
if($arrMonths31days -contains $Month) 
    {$endMonth = 31}

# check if $Month value is a month with 30 days and if true, set the value of $endMonth to 30
    elseif($arrMonths30days -contains $Month) 
    {$endMonth = 30}

# check if $Month value is February
    elseif ($Month -eq "February")
    {$endMonth = 28}

# $Month value is not actually a English month name
    else {
    Write-Host -ForegroundColor Red $outOfMonth
    return
    }

$fileName = "_"+$Month+"_"+$Mailbox+"_"+(Get-Date -Format "MMMdd_HHmmss")+".csv"

# find the database name where mailbox is hosted
$dbName = ((Get-Mailbox $Mailbox).Database).Name

# find the servers in the DAG that hosts the mailbox
$arrServers = ((Get-MailboxDatabase -Identity $dbName).Servers).Name

foreach($server in $arrServers){
    Get-MessageTrackingLog -Server $server -Start "1 $Month $year 00:00:00" -End "$endMonth $Month $year 23:59:59" -Recipients $Mailbox -ResultSize Unlimited | Select-Object Timestamp,RecipientCount,MessageSubject,Sender | Export-Csv ($server+$fileName) -Encoding ASCII -NoTypeInformation
    }
}
