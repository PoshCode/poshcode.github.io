$x = New-Object PSObject | 
      Add-Member -MemberType ScriptMethod -Name Test -Value {
          param($message=$(Read-Host "Message")) 
          return "This is the message: $message"
      } -Passthru

# You should now call $x.Test("Hello World")
# But if you call $x.Test() it will prompt you for the $message value

