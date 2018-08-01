$ELIMServer  = $Env:ComputerName
$ELIMChannel = "ELIM"
$ELIMUser    = $Env:UserName

function New-ELIMUser {
#.Synopsis
#  Send a message to the ELIM (Event Log Instant Messaging) Log
[CmdletBinding()]
param ( 
# The Computer whose event logs will be used for instant messaging
[String]$Server   = $ELIMServer,
# The Log Name to use for instant messaging
[Alias("To")]
[String]$Channel  = $ELIMChannel,
# The "Source" for messages that you will send
[Alias("As")]
[String]$UserName = $ELIMUser
)

    New-EventLog -LogName $Channel -Source $UserName -ComputerName $Server -EA 0 -EV Failed
    if($Failed -and $Failed[0].Exception.Message.StartsWith( "The `"$UserName`" source is already registered" )) {
        
    }
    sleep -milli 500
    if(!(Get-EventLog -ComputerName $Server -list |where {$_.Log -eq $Channel })) {
        throw "Failed to register on server, please check server and username and try again:`n`n$Failed"
    }
    Set-ELIMDefaults @PSBoundParameters
}

function Set-ELIMDefaults {
#.Synopsis
#  Set your default username for the ELIM (Event Log Instant Messaging) Log
#.Description
#  Normally your current computer ($Env:ComputerName), UserName ($Env:UserName), and the "ELIM" log are used unless you overwrite it on the console.
#  This allows you to override those defaults
param ( 
# The Computer whose event logs will be used for instant messaging
[String]$Server   = $ELIMServer,
# The Log Name to use for instant messaging
[Alias("To")]
[String]$Channel  = $ELIMChannel,
# The "Source" for messages that you will send
[Alias("As")]
[String]$UserName = $ELIMUser
)
$script:ELIMServer  = $Server
$script:ELIMChannel = $Channel
$script:ELIMUser    = $UserName
}

function Send-ELIMMessage {
#.Synopsis
#  Send a message to the ELIM (Event Log Instant Messaging) Log
[CmdletBinding()]
param(
# The message to send
[Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
[String]$Message,
# The Computer whose event logs will be used for instant messaging
[String]$Server   = $ELIMServer,
# The Log Name to use for instant messaging
[Alias("To")]
[String]$Channel  = $ELIMChannel,
# The "Source" for messages that you will send
[Alias("As")]
[String]$UserName = $ELIMUser
)
process {
    Write-Verbose "Write-EventLog -ComputerName $Server -LogName $Channel -Source $UserName -EventID 1 -Message '$Message'"
    Write-EventLog -ComputerName $Server -LogName $Channel -Source $UserName -EventID 1 -Message $Message
}
}


Set-Alias Msg Send-ELIMMessage

function Start-ELIM {
[CmdletBinding()]
param(
# The Computer whose event logs will be used for instant messaging
[String]$Server   = $ELIMServer,
# The Log Name to use for instant messaging
[Alias("To")]
[String]$Channel  = $ELIMChannel,
# The "Source" for messages that you will send
[Alias("As")]
[String]$UserName = $ELIMUser,
# Time stamp format for output
$TimeStampFormat = "dd-MM hh:mm:ss",
# The default background color for instant messages
$Background = "Black",
# The highlight color for instant messages
$HighlightBackground = "White",
# The regular expression for highlighting (defaults to your username)
$HighlightRegex = ".*${UserName}.*",
# Available colors for user names. You can use any of "Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White" -- but you want to exclude any of them which aren't readable.
[ConsoleColor[]]$Colors = $("DarkGreen", "DarkCyan", "DarkRed", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White"),
[Switch]$Force
)
end { 

    Set-ELIMDefaults -Server $Server -Channel $Channel -UserName $UserName

try {
    $exists = [System.Diagnostics.EventLog]::SourceExists($UserName, $Server)
} catch {}

if(!$exists) {
    Write-Warning "Your user name ($UserName) doesn't exist on '$Server', you won't be able to send messages until you run New-ELIMUser in an elevated console"
} else {
    $RealChannel = [System.Diagnostics.EventLog]::LogNameFromSourceName($UserName,$Server)
    if($Channel -ne $RealChannel -and !$Force) {
        throw "Your username is registered to SEND to '$RealChannel' not '$Channel', if you want to LISTEN to '$Channel' anyway, use -Force"
    }
}

$elim = Get-EventLog -ComputerName $Server -list | where { $_.Log -eq $Channel }

if(!$elim) {
    throw "Failed to connect to the '$Channel' channel on the server ($Server)."
} else {
    Register-ObjectEvent $elim EntryWritten -Action {
        if($Event.Entry.Source -ceq $Event.MessageData.UserName) { return }

        $Message =  "[{0:$($Event.MessageData.TimeStampFormat)}] {1}: {2}" -f $EventArgs.Entry.TimeGenerated, $EventArgs.Entry.Source, $EventArgs.Entry.Message
        $Color = $Event.MessageData.Colors[(([int[]][char[]]"$($EventArgs.Entry.Source)" | measure -sum ).Sum % $Event.MessageData.Colors.Count)]

        Write-Host "$(([int[]][char[]]"$($EventArgs.Entry.Source)" | measure -sum ).Sum) % $($Event.MessageData.Colors.Count) = $(([int[]][char[]]"$($EventArgs.Entry.Source)" | measure -sum ).Sum % $Event.MessageData.Colors.Count) = $Color"
        if($Message -match $Event.MessageData.HighlightRegex) {
            Write-Host $Message -ForegroundColor $Color -BackgroundColor $Event.MessageData.HighlightBackground
        } else {
            Write-Host $Message -ForegroundColor $Color -BackgroundColor $Event.MessageData.Background
        }
    } -MessageData @{
        Server = $Server
        Channel = $Channel
        UserName = $UserName
        TimeStampFormat = $TimeStampFormat
        Background = $Background
        HighlightBackground = $HighlightBackground
        HighlightRegex = $HighlightRegex
        Colors = $Colors
    }
}
}
}

Export-ModuleMember -Function * -Alias * 
