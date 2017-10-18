function Test-Host
{
    <#
        .Synopsis
            Test a host for connectivity using either WMI ping or TCP port
        .Description
            Allows you to test a host for connectivity before further processing
        .Parameter Server
            Name of the Server to Process.
        .Parameter TCPPort
            TCP Port to connect to. (default 135)
        .Parameter Timeout
            Timeout for the TCP connection (default 1 sec)
        .Parameter Property
            Name of the Property that contains the value to test.
        .Example
            # To test a list of hosts.
            cat ServerFile.txt | Test-Host | Invoke-DoSomething
        .Example
            # To test a list of hosts against port 80.
            cat ServerFile.txt | Test-Host -tcp 80 | Invoke-DoSomething   
        .Example
            # To test the output of Get-ADComputer using the dnshostname property
            Get-ADComputer | Test-Host -property dnsHostname | Invoke-DoSomething    
        .OUTPUTS
            Object
        .INPUTS
            object
        .Link
            N/A
         NAME:      Test-Host
         AUTHOR:    YetiCentral\bshell
         Website:   www.bsonposh.com
         LASTEDIT:  02/04/2009 18:25:15
        #Requires -Version 2.0
    #>
    [CmdletBinding()]
    
    Param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$True)]
        [string]$Server,
        [Parameter()]
        [int]$TCPPort,
        [Parameter()]
        [int]$timeout=1000,
        [Parameter()]
        [string]$property
        )
    Begin
    {
        function TestPort {
            Param($srv,$tport,$tmOut)
            Write-Verbose " [TestPort] :: Start"
            Write-Verbose " [TestPort] :: Setting Error state = 0"
            $ErrorActionPreference = "SilentlyContinue"
            
            Write-Verbose " [TestPort] :: Creating [system.Net.Sockets.TcpClient] instance"
            $tcpclient = New-Object system.Net.Sockets.TcpClient
            
            Write-Verbose " [TestPort] :: Calling BeginConnect($srv,$tport,$null,$null)"
            $iar = $tcpclient.BeginConnect($srv,$tport,$null,$null)
            
            Write-Verbose " [TestPort] :: Waiting for timeout [$timeout]"
            $wait = $iar.AsyncWaitHandle.WaitOne($tmOut,$false)
            # Traps     
            trap 
            {
                Write-Verbose " [TestPort] :: General Exception"
                Write-Verbose " [TestPort] :: End"
                return $false
            }
            trap [System.Net.Sockets.SocketException]
            {
                Write-Verbose " [TestPort] :: Exception: $($_.exception.message)"
                Write-Verbose " [TestPort] :: End"
                return $false
            }
            if(!$wait)
            {
                $tcpclient.Close()
                Write-Verbose " [TestPort] :: Connection Timeout"
                Write-Verbose " [TestPort] :: End"
                return $false
            }
            else
            {
                Write-Verbose " [TestPort] :: Closing TCP Sockett"
                $tcpclient.EndConnect($iar) | out-Null
                $tcpclient.Close()
            }
            if($?){Write-Verbose " [TestPort] :: End";return $true}
        }
        function PingServer {
            Param($MyHost)
            Write-Verbose " [PingServer] :: Pinging $MyHost"
            $pingresult = Get-WmiObject win32_pingstatus -f "address='$MyHost'"
            Write-Verbose " [PingServer] :: Ping returned $($pingresult.statuscode)"
            if($pingresult.statuscode -eq 0) {$true} else {$false}
        }
    }
    Process
    {
        Write-Verbose ""
        Write-Verbose " Server   : $Server"
        if($TCPPort)
        {
            Write-Verbose " Timeout  : $timeout"
            Write-Verbose " Port     : $TCPPort"
            if($property)
            {
                Write-Verbose " Property : $Property"
                if(TestPort $Server.$property -tport $TCPPort -tmOut $timeout){$Server}
            }
            else
            {
                if(TestPort $Server -tport $TCPPort -tmOut $timeout){$Server} 
            }
        }
        else
        {
            if($property)
            {
                Write-Verbose " Property : $Property"
                if(PingServer $Server.$property){$Server} 
            }
            else
            {
                Write-Verbose " Simple Ping"
                if(PingServer $Server){$Server}
            }
        }
        Write-Verbose ""
    }
}
