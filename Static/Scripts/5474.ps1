
function Check-WindowsPreview
{
	PARAM(
		[switch]$WaitForIt
	)

	BEGIN
	{
		$webClient = new-object System.Net.WebClient
		$webClient.Headers.Add("user-agent", "PowerShell Script")
		
		do
		{
			try
			{
 				$startTime = Get-Date
 				$output = $webClient.DownloadString("http://preview.windows.com")
 				$endTime = get-date

	 			if ($output -like "*so please check back soon*")
				{
					Write-Output $(new-object -type PSObject -Property @{
     						Released = "NotYet"
     						StartTime = $startTime
     						EndTime = $endTime
						Duration = ($endTime - $startTime).TotalSeconds
					})
				}
				else
				{
					Write-Output $(new-object -type PSObject -Property @{
     						Released = "Yes"
     						StartTime = $startTime
     						EndTime = $endTime
						Duration = ($endTime - $startTime).TotalSeconds
					})
				}
			}
			catch
			{
				Write-Output $(new-object -type PSObject -Property @{
     					Released = "Unknown: $($_.Exception.Message)"
     					StartTime = $startTime
     					EndTime = $endTime
					Duration = ($endTime - $startTime).TotalSeconds
				})
			}

 			if ($WaitForIt) { Sleep(5) }
		}
		while ($WaitForIt)
	}

}
