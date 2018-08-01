$x = New-Object PSObject | Add-Member -MemberType ScriptMethod -Name Test -Value {
    .{
        param (	
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
	        [string]$Message
        )
        "This is the message: $Message"
    } @args 
} -PassThru

# You should now call $x.Test("Hello World")
# But if you call $x.Test() it will prompt you for the $message value
