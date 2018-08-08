###Variable to be changed
##Server Setup
Write-host "Start time: "(get-date).ToShortTimeString()""
$startDate=(get-date).addDays(-1) ##-1 equates to previous date
$endDate=(get-date) ##Current Date
$Server = $(Get-WmiObject Win32_Computersystem).name
Write-host "Server and Dates set - "(get-date).ToShortTimeString()""

##Emails setup
$smtpserver = "SMTP Server"
$smtpfrom = "email.com" ##From email
$smtpto = "email.com"  ##To email
$messagesubject = "Recent Security Events on $server for Last 24hours" #email subject
write-host "Email settings set - "(get-date).ToShortTimeString()""
###End variable to be changed 
 
# Store each event from the Security Log with the specificed dates and computer in an array $flog = failure logins $slog = Successful logins
#Searches for FailureAudit entry type
Write-host "Searching for failure logs - Start time: "(get-date).ToShortTimeString()""
$flog = Get-Eventlog -LogName Security -ComputerName $server | where-object {$_.EventID -eq "529" -and $_.TimeGenerated -gt $startDate -and $_.TimeGenerated -lt $endDate}
Write-host "Complete search for failure logs - End time: "(get-date).ToShortTimeString()""
#searches for EventID 528
Write-host "Searching for successful logs - Start time: "(get-date).ToShortTimeString()""
$slog = Get-eventlog -LogName Security -ComputerName $server | Where-Object {$_.EventID -eq "528" -and $_.TimeGenerated -gt $startDate -and $_.TimeGenerated -lt $endDate}
Write-host "Complete search for successful logs - End time: "(get-date).ToShortTimeString()""

Write-host "Searching for failed  RSA logs - End time: "(get-date).ToShortTimeString()""
$rflog = get-eventlog -LogName Application -ComputerName $server   | Where-Object {$_.EventID -eq "106" -and $_.TimeGenerated -gt $startDate -and $_.TimeGenerated -lt $endDate}
Write-host "Complete search for failed  RSA logs - End time: "(get-date).ToShortTimeString()""

Write-host "Searching for successful RSA logs - Start time: "(get-date).ToShortTimeString()""
$rsLog = Get-eventlog -LogName Application -ComputerName $server | Where-Object {$_.EventID -eq "105" -and $_.TimeGenerated -gt $startDate -and $_.TimeGenerated -lt $endDate}
Write-host "Complete search for successful  RSA logs - End time: "(get-date).ToShortTimeString()""

Write-host "Searching for Event ID 550 - Start time: "(get-date).ToShortTimeString()""
$dosLog = Get-eventlog -LogName Security -ComputerName $server | Where-Object {$_.EventID -eq "550" -and $_.TimeGenerated -gt $startDate -and $_.TimeGenerated -lt $endDate}
Write-host "Complete search for Event ID 550 - End time: "(get-date).ToShortTimeString()""

Write-host "Searching for Event ID 612 - Start time: "(get-date).ToShortTimeString()""
$saLog = Get-eventlog -LogName Security -ComputerName $server | Where-Object {$_.EventID -eq "612" -and $_.TimeGenerated -gt $startDate -and $_.TimeGenerated -lt $endDate}
Write-host "Complete search for Event ID 612 - End time: "(get-date).ToShortTimeString()""

#Loop through each security event
Write-host "Looping through events to compile logs - Start time: "(get-date).ToShortTimeString()""
if($flog -eq $null){
    [string]$messagebodyf = ""
    $messagebodyf =  "No failed login events." + "`r`n"
	}
    else{
        [string]$messagebodyf = ""
            foreach ($i in $flog){ 
                $table = @("Date: "," - User: "," - Caller Domain: "," - Workstation: "," - IP: ") 
                $time = $table[0] + $i.TimeGenerated 
                $User = $table[1] + $i.ReplacementStrings[0]
	            $domain = $table[2] + $i.ReplacementStrings[1]
				$Workstation = $table[3] + $i.ReplacementStrings[5]
				$ip = $table[4] + $i.ReplacementStrings[11]
                $break = "`n`n"
                $messagebodyf = $messagebodyf + $time, $user + $domain + $workstation + $ip + "`r`n"
            }
        }
If($slog -eq $null){
    [string]$messagebodys = ""
    $messagebodys = "No Successful login events." + "`r`n"
    }
    else{
    [string]$messagebodys = ""
            foreach ($s in $slog){ 
				$table = @("Date: "," - User: "," - Caller Domain: "," - Workstation: "," - IP: ") 
                $time = $table[0] + $s.TimeGenerated 
                $user = $table[1] + $s.ReplacementStrings[0]
		        $domain = $table[2] + $s.ReplacementStrings[1]
                $break = "`n`n"
                $messagebodyS = $messagebodys + $time, $user + $domain + "`r`n"
            }
        }

if($rflog -eq $null){
	[string]$messagebodyrf= ""
	$messagebodyrf =  "No failed login events for RSA Tokens." + "`r`n"	
	}
    else{
        [string]$messagebodyrf = ""
            foreach ($rf in $rslog){ 
                $table = @("Date: "," - User: ", " - Caller Domain: ") 
                $time = $table[0] + $rf.TimeGenerated 
                $user = $table[1] + $rf.ReplacementStrings
                $break = "`n`n"
                $messagebodyrf = $messagebodyrf + $time, $user + "`r`n"
            }
        }

if($rslog -eq $null){
	[string]$messagebodyrs = ""
	$messagebodyrs =  "No successful login events for RSA Tokens." + "`r`n"	
	}
    else{
        [string]$messagebodyrs = ""
            foreach ($rs in $rslog){ 
                $table = @("Date: "," - User: ", " - Caller Domain: ") 
                $time = $table[0] + $rs.TimeGenerated 
                $user = $table[1] + $rs.ReplacementStrings
                $break = "`n`n"
                $messagebodyrs = $messagebodyrs + $time, $user + "`r`n"
            }
        }
		
if($doslog -eq $null){
    [string]$messagebodydos = ""
    $messagebodydos =  "Windows Event ID 550 - No record of possible denial-of-service (DoS) attack on $server." + "`r`n"
	}
    else{
        [string]$messagebodydos = ""
		$messagebodydos =  "Windows Event ID 550 - Possible denial-of-service found.  Please check $server" + "`r`n"
        }

if($salog -eq $null){
    [string]$messagebodysa = ""
    $messagebodysa =  "Windows Event ID 612 - No record of a system audit policy change on $server." + "`r`n"
	}
    else{
        [string]$messagebodysa = ""
		$messagebodysa =  "Windows Event ID 612 - A system audit policy was change recently on $server." + "`r`n"
        }
				
		
Write-Host "Loop complete - End time: "(get-date).ToShortTimeString()""
Write-host "Begin email - Start time: "(get-date).ToShortTimeString()""		
		##Begin send email portion
		try{		
			$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
			$messagebody = "Failed Windows Logins: `n" + $messagebodyF + $break + "Successful Windows Logins: `n" + $messagebodyS + $break + "Denied RSA Token Access: `n" + $messagebodyrf + $break + "Successful RSA Token Access: `n" + $messagebodyrs + $break + "System Audit Policy:  `n" + $messagebodysa + $break + "Possible denial-of-service (DoS) attack: `n" + $messagebodydos
			$smtp.Send($smtpFrom,$smtpTo,$messagesubject,$messagebody)
			Write-host "email sent - End time: "(get-date).ToShortTimeString()""		
			}
        catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        write-warning "Email not sent based on error.  $ErrorMessage and $FailedItem"
        }

