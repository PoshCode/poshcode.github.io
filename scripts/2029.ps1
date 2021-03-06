### VARIABLES ###

#Stop the script if an error ever occurs
$ErrorActionPreference = "stop"

#Base Directory
$BaseDir="C:\Scripts"

#Place for Migration Reports
$ReportFileDir="C:\Scripts\Logs"

#Exclusion List of Mailboxes to Not Move. This should be a return-separated list of mailbox display names to avoid.
$ExclusionListFile="$BaseDir\ExcludedMailboxes.txt"

#Special Mailboxes. These are mailboxes that should be completely exempt, including errorChecking to see if they exist, such as non-standard system mailboxes or others that may cause problems with migration.
$SpecialMailboxes="$BaseDir\SpecialMailboxes.txt"

#Excluded 2003 Hosts not to Scan for Mailboxes
$ExcludedHosts="$BaseDir\ExcludedHosts.txt"

#Number of Mailboxes to Move in this Batch 
$MailboxCount = 10000

#Output if a user is excluded by the Exclusion List
$ShowExclusions=$true

#Migrate for real. Only do a "what-if" evaluation if false.
$MigrateMailboxes = $false

### Functions ###

#Select-MigrateMailboxDatabase
#***READ ME*** REPLACE THE REGEX AND Mailbox Database Names as appropriate.
function Select-TargetDatabase ($NameToMatch) {
    $TargetMailboxDatabaseName = switch -regex ($NameToMatch) {
            "^[0-9].*" {"1 - Mailbox Store A - D"}
            "^[a-d].*" {"1 - Mailbox Store A - D"}
            "^[e-h].*" {"2 - Mailbox Store E - H"}
            "^[i-l].*" {"3 - Mailbox Store I - L"}
            "^[m-p].*" {"4 - Mailbox Store M - P"}
            "^[q-t].*" {"5 - Mailbox Store Q - T"}
            "^[u-z].*" {"6 - Mailbox Store U - Z"}
            default {throw "No Datastore was matched by Select-MigrateMailboxDatabase for $MailboxDisplayName. Check that the user's name will be matched by the select-targetdatabase matching criteria"}
    }
    return $TargetMailboxDatabaseName
}

### INITIALIZE ###

#Load Exchange Snapins if not present
if (!(get-pssnapin Microsoft.Exchange.Management.Powershell.Admin -erroraction SilentlyContinue)) {
    write-host -fore cyan "Loading Exchange Powershell Snapins..."
    get-pssnapin -registered | where {$_.name -match "Microsoft.Exchange"} | add-pssnapin
}

#Load 2003 Statistics Formatting Module
if (!(get-module Format-2003MailboxStatistics)) {import-module "$BaseDir\Format-2003MailboxStatistics.psm1"}

### END INITIALIZE ###

### SCRIPT ###
write-host -fore darkcyan "===Mailbox Move Script START==="


#Trim any leading/trailing whitespace from the exclusion list
$ExclusionList = (get-content $ExclusionListFile) | foreach {$_.trim()}

#Validate Exclude List. Ensure every item in the exclusion list has a corresponding mailbox. This way we can be sure we don't accidentally miss someone because their name was misspelled.
write-host -fore darkcyan "= Validating Exclusion List..." -nonewline
$ExclusionList | where {(get-content $SpecialMailboxes) -notcontains $_} | foreach {
    if (!(get-mailbox "$_" -errorAction SilentlyContinue)) {throw "Validating the Exclusion List failed. There is no Exchange Mailbox with the display name $_. Verify that the name in the Exclusion List is correct and try again."}
}
write-host -fore green "SUCCESS"

###Collect mailbox statistics on all legacy mailboxes (aka not migrated to 2007) in the organization.

#First Get a list of all Exchange 2003 Servers in the organization
write-host -fore darkcyan "= Collecting Exchange 2003 Server Information..." -nonewline
$EX2003Servers = get-exchangeserver | where {$_.AdminDisplayVersion -match "6.5"}
write-host -fore green "SUCCESS"

#Collect Mailbox Statistics for Each Server
$2003MailboxStats = @()
$EX2003Servers | where {(get-content $ExcludedHosts) -notcontains $_.Name} | foreach {
    $ServerName = $_.Name
    write-host -fore darkcyan "= Collecting Exchange 2003 Mailbox Statistics on $ServerName..." -nonewline
    $MailboxWMIInfo = Get-WMIObject -ComputerName $ServerName `
        -Namespace "root/MicrosoftExchangeV2" -Class "Exchange_Mailbox"
    $2003MailboxStats += $MailboxWMIInfo | Format-2003MailboxStatistics
    write-host -fore green "SUCCESS"
}

#Check if each Mailbox is on the exclusion list, and filter it out if it is. We do this before mailbox selection in case the top X results are all excluded people, so we don't have to run the script a second time.
write-host -fore darkcyan "= Excluding Mailboxes on the Exclusion, System, and Keyword Lists..."

$MailboxMoveCandidates = $2003MailboxStats | `
where {(get-content $SpecialMailboxes) -notcontains "$($_.MailboxDisplayName)"} | `
where {
        #@@BUGFIX - This logic is not 100% sound, several implications are made. Works fine but could be cleaner.
        
        #Set some variables for ease-of-use later
        $candidate = $_
        $candidateName = $candidate.MailboxDisplayName.Trim()
        
        
        #Filter Out System Mailboxes
        if ($candidateName -match 'SMTP ' ) {return $false}
        elseif ($candidateName -match 'SystemMailbox'){return $false}
        
        #Filter Out Disabled Users
        elseif ($candidate.DateDiscoveredAbsentInDS) {
            if ($showExclusions) {write-host -fore yellow "= * Skipping $candidateName because the mailbox has no corresponding Active Directory Object."}
            return $false;
        }
        
        #Verify user has a corresponding AD object
        elseif (!(get-mailbox $candidate.Identity -erroraction silentlyContinue)) {
            if ($showExclusions) {write-host -fore red "= * Skipping $candidateName because could not get mailbox info. Verify that the user has an Active Directory Account."}
            return $false;
        }
        
        #Verify a user is not on the exclusion List.
        elseif ($ExclusionList -notcontains "$candidateName") {
            return $true;
        }
        

        
        #Exclude everything else as a safety check if it doesn't meet the above rules.
        else {
            if ($showExclusions) {write-host -fore yellow "= * $candidateName was excluded"}
            return $false;
        }
}

write-host -fore green "= Excluding Mailboxes SUCCESS"

#Select Top X Users
$MailboxesToMove = $MailboxMoveCandidates | sort size | select -first $MailboxCount

#Display Mailboxes that will be moved and where they will be moved to. We do this by creating new objects with Select that have a new targetDatastore parameter, and run the detection program to find the correct datastore and populate.
$MBDisplay = $MailboxesToMove | select MailboxDisplayName,@{Name='Size (KB)';Expression={$_.size}},serverName,NameToMatch,targetDatabase | foreach {
    $_.nameToMatch = $_.MailboxDisplayName.split() | select -last 1
    $_.targetDatabase = Select-TargetDatabase "$($_.nameToMatch)";$_
}

#Separated this out so that it will process all objects BEFORE showing the out-gridview in case of any errors.
$MBDisplay | out-gridview -title "List of Mailboxes to Migrate in This Batch"

if ((read-host "Do you wish to move these $MailboxCount users? Type MIGRATE to perform the migration or anything else to exit.") -notlike "MIGRATE") {throw "Migration Cancelled at User Request";exit 10}

#Perform the Migration.

    $MailboxesToMove | foreach {
        $mailboxToMove = get-mailbox $_.Identity
        #@@BUGFIX - This is sloppy, would be better to query the AD last name. Is fine for 99% of users.
        $NameToMatch = $_.MailboxDisplayName.split() | select -last 1
        $targetDatabaseName = Select-TargetDatabase $NameToMatch
        #@@BUGFIX - This is also sloppy, but we would need all kinds of logic to get the database server and storage group first and this works just as well for 99% of cases as long as target datastore names are unique (they have to be in EX2010).
        $targetDatabase = get-mailboxdatabase | where {$_.name -like "$targetDatabaseName"}
        $reportFileName = "$ReportFileDir\$($mailboxToMove.Alias)-$(get-date -format "yyyy-MMM-dd-HHmmss").xml"
        
        #Just do a whatif unless MigrateMailboxes is set to true        
        if ($MigrateMailboxes) {move-mailbox $mailboxToMove -targetdatabase $targetDatabase -reportfile $reportFileName -Confirm $false}
        else {move-mailbox $mailboxToMove -targetdatabase $targetDatabase -reportfile $reportFileName -whatif}
    }

#Free Up Memory by deleting variable we don't need anymore.
#remove-variable -name MailboxMoveCandidates

###TODO: Rewrite 2003Stats as a pipeline function, get stats, sort by name and filter, exclude, and then kick off move mailbox with -whatif unless MigrateMailboxes is set.
