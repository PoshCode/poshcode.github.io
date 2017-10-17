#Email Alert Parameters

$to = "user@mydomain.com"

$from = "unreachable@mydomain.com"

$smtpserver = "my_exchange_server"

 

#Array of computers to test

$Computers = ("comp1" , "comp2" , "comp3" , "comp4")

#Variable to hold INT value 0
$zero = 0

Foreach ($Computer in $Computers)

    {

    if

        (
#Checks for a file with the host computers name in the Reports folder and if it doesn't exist creates it with content 0
        Test-Path $("C:\Reports\" + $Computer + ".txt")

        )

        {

        }

        else

        {

        $zero > $("C:\Reports\" + $Computer + ".txt")

        }
#Reads the content of the file and saves to variable as text
    $FailedPings = Get-Content $("C:\Reports\" + $Computer + ".txt")
#Converts the value to INT
    $INT_FailedPings  = [INT]$FailedPings
#Actually runs the ping test
    $PingTest = Test-Connection -ComputerName $Computer -count 1

    if

        (
#If ping is unsuccessful 
        $PingTest.StatusCode -ne "0"

        )

        {

    while

        (
#If previous failed pings value is less or equal to 3
        $INT_FailedPings  -le 3

        )

        {
#Increment the value by 1
        $INT_FailedPings++
#Write the value out to the reports folder file for this host
        $INT_FailedPings  > $("C:\Reports\"  + $Computer  + ".txt")
#Send an alert of failed ping
        Send-MailMessage -to $to -subject "Warning, Host $Computer is down. You will only receive 4 of these messages!" -from $from  -body "Ping to $Computer failed, you will only receive 3 of these messages!" -smtpserver $smtpserver

        }

        }

   elseif

        (
#If previous checks have failed the value will be non zero, as checks are now working sets the value back to zero and alerts that host is back up
        $INT_FailedPings  -ne 0

        )

        {

        $zero > $("C:\Reports\" + $Computer + ".txt")

        Send-MailMessage -to $to -subject "Host $Computer is back up" -from $from  -body "Panic over"  -smtpserver $smtpserver

        }

    else
#If ping is successful and past pings were successful do nothing
        {

        }

    }
