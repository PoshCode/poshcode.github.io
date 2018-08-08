function Start-MyTranscript
{
	Param
	(
		[Parameter(Mandatory=$true,Position=0)]
		[string] $Path
	)# of Param
	
	Process
	{
		$fileextension = "txt"
		$filenamePrefix = [System.DateTime]::Now.ToString("yyyy-MM-dd")
		$existingFiles = Get-ChildItem (Join-Path $Path "$filenamePrefix.*.Transcript.$fileextension") | Sort-Object Name
		if($existingFiles)
		{
			if($existingFiles.Count -gt 1)
			{
				$existingFilename = $existingFiles[-1].Name
			}# if we have more than one file
			else
			{
				$existingFilename = $existingFiles.Name
			}# if we only have one file
			
			$fileNumber = $existingFilename.Substring($filenamePrefix.Length + 1)
			$fileNumber = $fileNumber.Substring(0, $fileNumber.IndexOf("."))
			[int] $iFileNumber = 9999
			if([Int32]::TryParse($fileNumber, [ref] $iFileNumber))
			{
				$iFileNumber++
			}# if we parsed the number
		}# if we have files
		else
		{
			$iFileNumber = 1
		}# if we don't have files
		
		if($iFileNumber)
		{
			$fileNumber = $iFileNumber.ToString("0000")
			$filename = "$filenamePrefix.$fileNumber.Transcript.$fileextension"

			if(!(Test-Path $Path))
			{
				New-Item $Path -Type Directory -Force
			}# create dir if it doesn't exist
			try
			{
				Start-Transcript -Path (Join-Path $Path $fileName) -Append -Force -NoClobber
			}# try to start the transcript
			catch
			{
				Write-Host "Unable to start transcript"
			}# catch any error
		}# if we got a filename	
	}# of Process
}# of Start-MyTranscript
