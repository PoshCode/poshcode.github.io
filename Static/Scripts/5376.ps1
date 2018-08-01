## DuckDNS Powershell
[scriptblock]$UpdateDuckDns = {
    $Encoding = [System.Text.Encoding]::UTF8;
    $duckdns_url = "https://www.duckdns.org/update?domains=YOUR_DOMAIN&token=YOUR_TOKEN&ip=";

    $HTTP_Response = Invoke-WebRequest -Uri $duckdns_url;
    $Text_Response = $Encoding.GetString($HTTP_Response.Content);

    if($Text_Response -ne 'OK'){
        Write-EventLog –LogName Application –Source "DuckDNS Updater" –EntryType Information –EventID 1 –Message "DuckDNS Update failed for some reason. Check your Domain or Token.";
    }
}

[scriptblock]$SetupRepeatingJob = {
    $RepeatTimeSpan = New-TimeSpan -Minutes 5;
    $DurationTimeSpan = New-TimeSpan -Days 1000;
    $At = $(Get-Date) + $RepeatTimeSpan;
    $UpdateTrigger = New-ScheduledTaskTrigger -Once -At $At -RepetitionInterval $TimeSpan -RepetitionDuration $DurationTimeSpan;
    Register-ScheduledJob -Name RunDuckDnsUpdate -ScriptBlock $UpdateDuckDns -Trigger $UpdateTrigger;
}

New-EventLog  –LogName Application –Source "DuckDNS Updater"
$StartTrigger = New-JobTrigger -AtStartup
Register-ScheduledJob -Name StartDuckDnsJob -ScriptBlock $SetupRepeatingJob -Trigger $StartTrigger
