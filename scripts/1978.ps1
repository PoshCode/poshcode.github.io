<#  
.SYNOPSIS  
    Multiple functions to build a config file and to use file to launch PerfMon background jobs.
.DESCRIPTION
    Multiple functions to build a config file and to use file to launch PerfMon background jobs.
.NOTES  
    Name: WinPerfv2.PS1
    Author: Boe Prox
    DateCreated: 28June2010 
    
    To-Do:
        1. Add a function for building the table where data will be stored at
        2. Build a GUI for the XML Config file build
.LINK  
    http://www.powershell.com
      
#> 

Function Build-SQLTable {
<#  
.SYNOPSIS  
    Builds a SQL Table named Counters on a SQL server database.
.DESCRIPTION
    Builds a SQL Table named Counters on a SQL server database.
.PARAMETER computer
    Name of the server that hosts the database
.PARAMETER database
    Name of the database that the table will be created on
.NOTES  
    Name: Build-SQLTable
    Author: Boe Prox
    DateCreated: 29June2010 
.LINK  
    http://www.powershell.com
.EXAMPLE  
    Build-SQLTable -computer 'Server' -database 'database'
          
#> 
[cmdletbinding(
	SupportsShouldProcess = $True,
	DefaultParameterSetName = 'perf',
	ConfirmImpact = 'low'
)]
param(
    [Parameter(
        Mandatory = $False,
        ParameterSetName = 'sql',
        ValueFromPipeline = $True)]
        [string]$computer,
    [Parameter(
        Mandatory = $False,
        ParameterSetName = 'sql',
        ValueFromPipeline = $True)]
        [string]$database     
        ) 
Write-Host -foregroundcolor Green "Building a SQL table: 'Counters' on Database: `'$($database)`' residing on Server: `'$($Computer)`'."        
#TSQL Statement to create table required for script
$tsql = CREATE TABLE Counters (ServerName varchar(20),"Date" varchar (50),CounterName varchar (25),CounterType varchar (25),InstanceName varchar (25),Data float (20))                
}

Function Get-UserChoice
    {
<#    
  .SYNOPSIS   
    Prompts user for choice.
  .DESCRIPTION   
    Prompts user for choice.
       
#>    
#Determine Values for Choice
$choice = [System.Management.Automation.Host.ChoiceDescription[]] @("&Continue","&Quit")

#Determine Default Selection
[int]$default = 0

#Present choice option to user
$userchoice = $host.ui.PromptforChoice(" ","Do you want to continue performance counters to the config file?",$choice,$default)

Return $userchoice
    }

Function Build-PerfConfig {

<#  
.SYNOPSIS  
    Builds an xml config file to be used with WinPerf.ps1 script
.DESCRIPTION
    Builds an xml config file to be used with WinPerf.ps1 script
.PARAMETER file
    Name of the file that will be saved
.PARAMETER flag
.PARAMETER assist    
.NOTES  
    Name: Build-PerfConfig.ps1
    Author: Boe Prox
    DateCreated: 28June2010 
.LINK  
    http://www.powershell.com
.EXAMPLE  
    Build-PerfConfig -file "exchange.xml"
          
#> 
[cmdletbinding(
	SupportsShouldProcess = $True,
	DefaultParameterSetName = 'perf',
	ConfirmImpact = 'low'
)]
param(
    [Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf',
        ValueFromPipeline = $True)]
        [string]$file = 'config.xml',
    [Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf',
        ValueFromPipeline = $True)]
        [string]$flag = $True,    
    [Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf',
        ValueFromPipeline = $True)]
        [switch]$assist            
)
#Clear screen
Clear

#Display welcome message
Write-Host -ForegroundColor Green -Backgroundcolor Black "Use this tool to build a config file for the WinPerf.ps1 perfmon script."
Write-Host -ForegroundColor Green -Backgroundcolor Black "You must know what performance counters you need before running this tool!"
Write-Host -ForegroundColor Green -Backgroundcolor Black "If you do not know, then it is advised to look up the counters before proceeding."
Write-Host -ForegroundColor Green -Backgroundcolor Black "`t`t`t`t`t`t`t`t`t`t"
Write-Host -ForegroundColor Green -Backgroundcolor Black "You can quit and save at anytime by typing 'q' and then pressing 'Enter' `n"

If ($assist) {
    Write-Host -ForegroundColor Cyan -Backgroundcolor Black "You will be assisted with determining what Categories, Counters and Instances to type. `n"
    }
    
#Prepare the array
$arr = @()

#Loop until user decides to quit and save xml file
While ($flag -eq $True) {
    #Create temporary array
    $t_array = "" | Select CategoryName, CounterName, InstanceName, CounterType, CounterHelp
    
    #Begin gathering information
    #Help user if requested from Assist switch
    If ($assist) {
        $flag2 = $False
        While ($flag2 -eq $False) {
            #Clear any errors
            $Error.Clear()
            Write-Host -ForegroundColor Green "Please enter a type of counter you are looking for."
            $d_counter = Read-Host "Category"
			Write-Host "Counter: $d_counter"
            Write-Host -ForegroundColor Green "Listing Categories based on your query. `n"
            #Configure error handling
            Write-Verbose "Configuring error preference"
            $ErrorActionPreference = 'stop'
            Try {
                Get-Counter -ListSet "*$d_counter*" | FT @{Name="Available Categories";Expression = "CounterSetName"}
                }
            Catch {
                Write-Warning "$_"
                }  
             #Only continue script if no errors occurred, otherwise try again     
             If (!($error)) {
                #Set flag so script can continue
                $flag2 = $True
                }   
            }  
        #Change preference back to continue                  
        $ErrorActionPreference = 'continue'
        }
    If ($flag -eq $True) {
        #Prompt for Category Name
        Write-Host -ForegroundColor Green "Enter the Category"
        $t_array.CategoryName = Read-Host "Category"
        
        #Change flag state if 'q' is typed
        If ($($t_array.CategoryName) -eq "q") {
            Write-Verbose "User typed 'q', quitting loop"
            $flag = $False
            }
        }
    #Help user if requested from Assist switch
    If ($assist) {
        Write-Host -ForegroundColor Green "Listing Counters based on your Category selection. `n"
        (Get-Counter -ListSet "$($t_array.CategoryName)").counter | % {$_.split("\")[2]}
        }
                
    If ($flag -eq $True) {
        #Prompt for Counter Name
        Write-Host -ForegroundColor Green "`nEnter the Counter Name"
        $t_array.CounterName = Read-Host "Counter"
        
        #Change flag state if 'q' is typed
        If ($($t_array.CounterName) -eq "q") {
            Write-Verbose "User typed 'q', quitting loop"
            $flag = $False
            }        
        }
    
    #Help user if requested from Assist switch
    If ($assist) {
        Write-Host -ForegroundColor Green "Listing Instance Names based on your Category selection. `n"
        $counter = $t_array.CounterName
		(get-counter -list "$($t_array.CategoryName)").pathswithinstances | % {
			$compare = ($_.split("(")[1]).split(")")[1]
			Try {
					If ("$counter" -match $compare) {
						($_.split("(")[1]).split(")")[0]
						}
					}
			Catch {
					Write-Verbose "$_"
					}
			}
        }        
    If ($flag -eq $True) {
        #Prompt for Instance Name
        Write-Host -ForegroundColor Green "`nEnter the Instance Name (can be blank if not needed)"
        $t_array.InstanceName = Read-Host "Instance Name"
        
        #Change flag state if 'q' is typed
        If ($($t_array.CategoryName) -eq "q") {
            Write-Verbose "User typed 'q', quitting loop"
            $flag = $False
            }        
        }
    
    #Process the temporay array with the main array
    If ($flag -eq $True) {
        Write-Verbose "Adding temp array to main array"
        $arr += $t_array
        }
        
    #Build the help comment and retrieve the Type of counter
    If ($flag -eq $True) {
        #We need to partially build this counter to retrieve the help comments
        $counter = New-Object System.Diagnostics.PerformanceCounter
        $counter.CategoryName = $($t_array.CategoryName)
        $counter.CounterName = $($t_array.CounterName)
        
        #Retrieve the help comments
        $t_array.CounterHelp = $counter.CounterHelp
        
        #Retrieve the Counter Type
        $t_array.CounterType = $counter.CounterType
        
        #Remove the $counter object
        $counter = $Null
        }
           
    #Ask user if they want to continue adding to the config file
    If ($flag -eq $True) {
            $answer = Get-UserChoice
            If ($answer -eq 1) {
                Write-Verbose "User typed 'q', quitting loop"
                $flag = $False
                }
        }

    } #End While Loop
    
    #Begin compiling xml file
    Write-Verbose "Building XML file: $file"
    $arr | Export-Clixml $file
    
    Write-Host -ForegroundColor Green "`n$file saved to $pwd"
    Write-Host -ForegroundColor Green "Opening $file to verify contents. If anything is missing, you will need to rebuild."
    Import-Clixml $file
    Return $file
} #End Build-PerfConfig Function

Function Get-PerfCounter {
<#  
.SYNOPSIS  
    Runs a pre-defined perfmon counter against a selected server or servers.
.DESCRIPTION
     Runs a pre-defined perfmon counter against a selected server or servers.
.PARAMETER interval
    Interval for performance counters. Default Value is 10 seconds.
.PARAMETER computers
    List or name of a computer to run against. Default Value is the local machine.
.PARAMETER endat
    When to end the perfmon counter. Default Value is 10 minutes.
.NOTES  
    Name: WinPerf.ps1
    Author: Boe Prox
    DateCreated: 28June2010 
         
.LINK  
    http://www.powershell.com
.EXAMPLE  
    Get-PerfCounter -configfile "OS_Baseline.xml" -computers Server -endat "06/20/2010 04:00 PM" -interval 60
    
    Uses the counters listed in the OS_Baseline.xml file on server 'Server' which will collect data at 60 second 
    intervals and will end on 06/20/2010 at 04:00PM.
          
#> 
[cmdletbinding(
	SupportsShouldProcess = $True,
	DefaultParameterSetName = 'perf',
	ConfirmImpact = 'low'
)]
param(
    [Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf',
        ValueFromPipeline = $True)]
        [array]$computers = $env:Computername, #Computer or computers to run perfmon against
	[Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf')]
        [string]$configfile, #Configuration file that lists what perfmon counters to check          
	[Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf')]
        [int]$interval = 10, #Time in seconds to wait before beginning next set of counters
	[Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf')]
        [datetime]$endat = (Get-Date).AddMinutes(10), #When to end the perf counter
	[Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf')]
        [string]$sqlsvr = "R49", #Name of the SQL server that hosts the perf counter database
	[Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf')]
        [string]$database = "PerfMon", #Name of the database storing the perf counters
	[Parameter(
        Mandatory = $False,
        ParameterSetName = 'perf')]
        [string]$file #List of host names to run perfmon against      
)
If ($computers -eq $Null -OR $computers -eq "") {
    $computers = $env:Computername
    }
If ($File) {
    $computers = Get-Content $file
    }    
$path = $pwd	
#Check to see if a config file was used, if not begin building the file.    
If ($configfile -eq $Null -OR $configfile -eq "") {
        Write-Warning "No config file given! `nLaunching file builder..."
        Start-Sleep -s 2
        Build-PerfConfig -assist
		$configfile = 'config.xml'
        }
ForEach ($computer in $computers) {

        #Initialize Background Job
        Start-Job -Name $computer -ArgumentList $computer, $configfile, $interval, $endat,$conn,$sqlsvr,$database,$path -ScriptBlock {
        param ($computer, $configfile, $interval, $endat,$conn,$sqlsvr,$database,$path)
        
        #Register SQL assemblies
        Write-Verbose "Loading SQL Assemblies"
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo.DLL") 
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO.DLL") 
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMOEnum.DLL") 
                
        #Create SQL Connection
        Write-Verbose "Creating SQL Connection"
        $conn = New-Object System.Data.SqlClient.SqlConnection("Data Source=$sqlsvr;
        Initial Catalog=$database; Integrated Security=SSPI")
        $conn.Open()
        $cmd = $conn.CreateCommand()
        
        #Define location of XML file
        Set-Location $path
        
        #Import the XML file
        Write-Verbose "Importing XML file $($configfile)"
        $counters = Import-Clixml $configfile
        
        #Set an increment
        Write-Verbose "Setting increment to 0"
        $inc = 0
        
        #Build Array for counters
        $total = $counters.Count
	    $perfcounter = New-Object 'object[]' $total        
        
        #Iterate through counters
        ForEach ($counter in $counters) {
        
            Write-Verbose "Looking at $($counter.CategoryName)"
            #Initialize the Performance Counters for the machine
            $perfcounter[$inc] = New-Object System.Diagnostics.PerformanceCounter
            $perfcounter[$inc].MachineName = $computer
            $perfcounter[$inc].CategoryName = $counter.CategoryName
            $perfcounter[$inc].CounterName = $counter.CounterName
            $perfcounter[$inc].InstanceName = $counter.InstanceName
            
            #Initial counter increment so the first value will not be 0
            $nothing = $perfcounter[$inc].NextValue()
            
            #Increment counter
            $inc++
            }
        $inc--    
        Write-Host -ForegroundColor Green $inc
                    		
        While ($endat -gt (get-date)) {
            
            #Iterate through perfcounters
            0..$inc | % {
                #Make variables for SQL command easier to read
                $CouName = $perfcounter[$_].CounterName
                $CatName = $perfcounter[$_].CategoryName
                $InsName = $perfcounter[$_].InstanceName
                $value = $perfcounter[$_].NextValue()
                
                #Create Date String
                $dt = (get-date) -f ""
                
                #Create query string
                #Must matching the table layout (Server, Date, CounterName, CounterType, InstanceName, Value)
                Write-Verbose "Sending PerfMon data for $catname \ $couname to SQL database"
                $cmd.CommandText = "INSERT INTO Counters (ServerName, Date, CounterName, CounterType, InstanceName, Data) VALUES ('$computer','$dt','$CouName','$CatName','$InsName','$Value')"  

                #Execute Query
                $cmd.ExecuteNonQuery() | Out-Null               
                }
            Start-Sleep -s $interval                
        	}                
        }
    }
}    

