#requires -version 2.0
function Start-ComputerJobs{
<#
    .NOTES
     Name: Start-ComputerJobs
     Author: Tome Tanasovski
     Created: 6/25/2010
     Modified: 6/25/2010
     Version: 1.1
     Website: http://powertoe.wordpress.com
        
    .SYNOPSIS
     Multithreads a scriptblock with jobs
 
    .DESCRIPTION
     The Start-ComputerJobs cmdlet runs a specified scriptblock within a maximum number of simultaneously spawned Powershell jobs.  
     
     You must pass a list of ComputerNames to it.  The names passed to the cmdlet will replace $computername within the scriptblock prior to starting each thread.
     
     This can be thought of as a multithreaded approach to a foreach loop.
 
    .PARAMETER ComputerName
     Specifies a list of computers that you wish to inject into your scriptblock.  The list of computer names will replace $computername in the script block.  This does not actually need to be a list of computer names.  It can be anything you wish to inject into your scriptblock.
     
    .PARAMETER ScriptBlock
     Specifies the commands to run in the background jobs.  Enclose the commands in braces ({}) or use $ExecutionContext.InvokeCommand.NewScriptBlock to create a scriptblock.
     
     The scriptblock must contain a $computername variable.  $computername will be replaced by each entry into the pipeline or from the parameter ComputerName.
     
    .PARAMETER Threads
     Specifies the maximum number of jobs that can be simultaneously running at any given time.
     
     This defaults to 10 if nothing is specified.
 
    .EXAMPLE
        "computer1","computer2","computer3","computer4","computer5" |Start-ComputerJobs -ScriptBlock {dir \\$computername\c$} 
        
    .INPUTS
        System.String        
 
    .OUTPUTS
        PSObject
        
        Returns the results of the commands in the job.  It is the data returned from receive-job.  If you're scriptblock contains write-host it will write that to the console as it is running.  To avoid this you should just return objects within your scriptblock. i.e. Instead of write-host "text" just use "text"
#>

    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ScriptBlock,
        [Parameter(Mandatory=$false)]
        [ValidateScript({$_ -gt 0})]
        [int32]$Threads = 10,
        [Parameter(Mandatory=$false)]
        [ValidateScript({$_ -gt 0})]
        [int32]$Sleep = 5
        
    )    
    BEGIN {        
        $firstrun = $true
        $computers = @()
        $curthreads = 0
        $jobs = @()
        $valid = $false
    }
    PROCESS {
        if ($firstrun) {
            $firstrun = $false
                        
            # Validate scriptblock - Making sure it has a $computername variable to use       
            if ($ScriptBlock -match '\$computername') {
                $valid = $true                
            } else {
                Write-Error 'You must specify a scriptblock that contains a variable called $computername'
                $valid = $false
            }
        }
        if ($valid) {
            foreach ($computer in $computername) {
                while ($jobs.count -eq $Threads) {
                    $newjobs = @()
                    $jobs |foreach {
                        Receive-Job $_.id
                        if ($_.state -eq "Running" -or $_.HasMoreData) {
                            $newjobs += $_
                        }
                        else {
                            $_ |Remove-Job
                        }
                    }
                    $jobs = $newjobs
                    if ($jobs.count -eq $Threads) {
                        sleep $sleep
                    }
                }                        
                $runscript = $ExecutionContext.InvokeCommand.NewScriptBlock(($ScriptBlock -replace '\$computername', "$computer"))
                Write-Verbose "Starting Job for computer: $computer"
                $jobs += Start-Job -ScriptBlock $runscript
                $curthreads++
            }
        }
    }
    END {
        while ($jobs.count -ne 0) {
            $newjobs = @()
            $jobs |foreach {
                Receive-Job $_.id
                if ($_.state -eq "Running" -or $_.HasMoreData) {
                    $newjobs += $_
                }
                else {
                    $_ |Remove-Job
                }
            }
            $jobs = $newjobs
            if ($jobs.count -gt 0) {
                sleep $sleep
            }            
        }  
    }
}
