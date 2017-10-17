    function Trace-Message {
        #.Synopsis
        #   A function to print trace messages with timings.
        #.Notes
        #   Does NOT currently support nested traces for the timer function
        #   You always need to call Trace-Message immediately upon entry
        #   And then call Trace-Message -KillTimer immediately upon exit
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
            [string]$Message,

            [switch]$AsWarning,

            [switch]$ResetTimer,

            [switch]$KillTimer
        )
        begin {
            if($Script:TraceVerboseTimer -eq $null) {
                $Script:TraceVerboseTimer = New-Object System.Diagnostics.Stopwatch
                $Script:TraceVerboseTimer.Start()
            } 
            elseif($ResetTimer) 
            {
                $Script:TraceVerboseTimer.Restart()
            }
        }

        process {
            $Message = "$Message - at {0} Line {1} | {2}" -f (Split-Path $MyInvocation.ScriptName -Leaf), $MyInvocation.ScriptLineNumber, $TraceVerboseTimer.Elapsed

            if($AsWarning) {
                Write-Warning $Message
            } else {
                Write-Verbose $Message
            }
        }

        end {
            if($KillTimer) {
                $Script:TraceVerboseTimer.Stop()
            }
        }
    }
