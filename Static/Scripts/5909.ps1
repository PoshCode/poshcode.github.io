
VERBOSE: Throttle: '20' SleepTimer '200' runSpaceTimeout '60' maxQueue '0' logFile 'C:\temp\log.log'
VERBOSE: Creating runspace pool and session states
VERBOSE: Creating empty collection to hold runspace jobs
VERBOSE: Adding SERVER1 to collection at 6/25/2015 4:16:15 PM
VERBOSE: Adding SERVER2 to collection at 6/25/2015 4:16:15 PM
VERBOSE: Test-Connection failed on SERVER1 ErrorMSG=Exception from HRESULT: 0xF4116408 Exception=System.Runtime.InteropServices.COMException (0xF4116408): Exception from HRESULT: 0xF4116408
   at System.Runtime.InteropServices.Marshal.ThrowExceptionForHRInternal(Int32 errorCode, IntPtr errorInfo)
   at System.Management.ManagementObjectCollection.GetEnumerator()
   at System.Management.ManagementObjectCollection.get_Count()
   at Microsoft.PowerShell.Commands.TestConnectionCommand.ProcessRecord()


#region CODE
$serverList = 'SERVER1', 'SERVER2'
$serverList | Invoke-Parallel -Throttle 20 -RunspaceTimeout 60 -ScriptBlock {

	$server = $_
	$isPingable = $false
        try
        {
            $isPingable = Test-Connection $server -BufferSize 16 -Quiet -Count 4 -ErrorAction Stop
        }
        catch 
        {
            Write-Verbose "Test-Connection failed on $server ErrorMSG=$($_.Exception.Message) Exception=$($_.Exception)"
        }
	$isPingable
}

