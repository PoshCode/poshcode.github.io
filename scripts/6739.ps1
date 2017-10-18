#Make new CSV File
$CSVFileName = "\\networkshare\folder\filename.csv"
"CSV,Header,With,Well,Named,Data,Columns" > $CSVFileName

$Timestamp = get-date -format o 

#Log file
$LogFileName = "\\networkshare\folder\logfile_$Timestamp.log"

#Function to do stuff with IP address
$SomeFunction = {
	param($IPAddress,$CSVFileName,$LogFileName)
	
    #do stuff with $IPAddress

    #To simulate some actual processing
    Sleep -s 1
    
    #format output for CSV file
    $CSVOutput = "Hello,$IPAddress,My,Name,Is,Mr,Bean"
    $CSVOutput >> $CSVFileName

    #always output any errors to a log file
    $error >> $LogFileName
}

#Array of subnets in our network
$Subnets = @("192.168.1.","192.168.2.","172.16.1.")

#Array will use to store different networks
$Networks=@()

foreach($Subnet in $Subnets)
{
    #Array will be using to store IP addresses in network
    $Network=@()

    #Build a list of IPs in that subnet
    $IPs = 1..254
    
    #Populate the subnet with IPs
    foreach($IP in $IPs){$Network+=($Subnet + $IP)}

    #Add the network to the array of networks
    $Networks += $Network
}

#Get total number of IP addresses
$NumIPaddresses = 0
foreach($Network in $Networks)
{
    foreach($IP in $Network){$NumIPaddresses++}
}

#### Now this is where the multi threading part begins ####

#Restrict Number of threads or you'll overload the server/computer
$NumThreads = 20
$ThreadsProcessed = 0

foreach($Network in $Networks)
{
    foreach($IP in $Network)
    {
        #Make sure we don't go over our maximum number of threads to process at any given time
        $NumJobsRunning = get-job -State Running
        while($NumJobsRunning.Count -ge $NumThreads)
        {
            #chill out for 30 seconds, wait for other threads to finish
            Sleep -s 30
            $NumJobsRunning = get-job -State Running
        }

        #Start a new thread
	    Start-Job -ScriptBlock $SomeFunction -ArgumentList $IP,$CSVFileName,$LogFileName
        $ThreadsProcessed++
        
        #Lets us know how we're progressing
        $Status = "$ThreadsProcessed of $NumIPAddresses threads processed"
        echo $Status
    }
}

#Check out our fancy CSV file
$CSVData = Import-CSV $CSVFileName
$CSVData | Out-gridview
