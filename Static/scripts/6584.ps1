## SETTINGS START ##

$date = Get-Date
$targetGroup = "Enter the name of your production WSUS target group here"
$updateFilter = "$_.title -notlike '*Server*' -and $_.title -notlike '*sharepoint*'"
$reportSMTP = "your SMTP server"
$reportTitle = "<h1>$env:computername</h1><h3>$updateCount updates approved for $targetGroup on $date.</h3>"
$reportFrom = "address status email comes from"
$reportTo = "address status email goes to"
$reportSubject = "Updates approved for $targetGroup"

## SETTINGS END ##

# Formatting for reporting email.

$reportHeader = @"
    <link rel="stylesheet" src="https://necolas.github.io/normalize.css/latest/normalize.css">
    <style>
        body {
            color: #222;
            font-family: sans-serif;
            font-size: 14px;
            margin: 2% 0;
        }
        h1 {
            font-size: 2em;
            font-weight: normal;
            padding: 0 2%;
        }
        h3 {
            font-size: 1.25em;
            font-weight: normal;
            padding: 0 2%;
        }
        table {
            border-collapse: collapse;
            width: 100%;
        }
        tr:nth-child(even) {
			background: #ADD8E6;
		}
        tr:nth-child(odd) {
            background: #E0FFFF;	
        }
        tr:first-child {
			background: #EEE;
		}
        th {
            border-bottom: 1px solid #999;
            font-weight: bold;
            text-align: left;
        }
        td,
        th {
            padding: .25em;
        }
        td:first-child,
        th:first-child    {
            padding-left: 2%;
        }
        td:last-child,
        th:last-child {
            padding-left: 2%;
        }
        h2 {
            font-size: 1.5em;
            font-weight: normal;
            margin: 1 0 .5%;
            padding: 0 2%;
        }
    </style>
"@

# Function to find updates applied per group.

function Get-WSUSgroupupdates {
Param ($target)

    [void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
    $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer()
    $updateScope = new-object Microsoft.UpdateServices.Administration.UpdateScope;
    $updateScope.UpdateApprovalActions =[Microsoft.UpdateServices.Administration.UpdateApprovalActions]::Install -bor [Microsoft.UpdateServices.Administration.UpdateApprovalActions]::Uninstall -bor [Microsoft.UpdateServices.Administration.UpdateApprovalActions]:: All -bor [Microsoft.UpdateServices.Administration.UpdateApprovalActions]::NotApproved
     
    $updates = $wsus.GetUpdates($updateScope)
     
    $groups = $wsus.GetComputerTargetGroups() | where {$_.name -eq $target}
    $updateRep = @() 
    
    foreach($update in $updates) {
     
        foreach($group in $groups) {
        
        $status = "Install"
     
            if ($update.GetUpdateApprovals($group).Count -ne 0)
            {$status = $update.GetUpdateApprovals($group)[0].Action}
            
            $updateRep += $update
                #@{Label='Title';Expression={$update.Title}},`
                #@{Label='Group';Expression={$group.Name}},`
                #@{Label='Status';Expression={$status}},`
                #@{Label='guid';Expression={$update.id.updateid}}
            }
        }

        $updateRep
    }

# Use function to find updates for target groups.

$testGroup = Get-WSUSgroupupdates -target "Workstations Test"
$corpGroup = Get-WSUSgroupupdates -target "Production Corporate"

# Compare test against target group to find difference.

Compare-Object $testGroup.id.updateid $corpGroup.id.updateid | `
    where {$_.SideIndicator -eq '<='} | `
    ForEach-Object  { $findDiff += $_.InputObject }

# Approve updates found in test that have not been applied for target group.

$allUpdate = $findDiff | where {$updateFilter} | `
    Approve-WsusUpdate -Action Install -TargetGroupName $targetGroup

# Get count of updates approved for reporting email sub header.

$updateCount = ($allUpdate.update.title).Count | Out-String

# Put updates into an HTML table with user friendly column names.

$outBody = $allUpdate.Update | select `
    @{Label='Update';Expression={$_.title}},`
    @{Label='Released';Expression={$_.creationdate}},`
    @{Label='Type';Expression={$_.UpdateClassificationTitle}} | `
    ConvertTo-Html -fragment -Property Update,Released,Type -PreContent $reportTitle

# Create final HTML with formatting applied and send as email.

$outHTM = ConvertTo-Html -Head $reportHeader -Body $outBody

Send-MailMessage `
   -SmtpServer $reportSMTP `
   -BodyAsHtml ($outHTM | out-string) `
   -From $reportFrom `
   -To $reportTo `
   -Subject $reportSubject
