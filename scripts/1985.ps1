function PromptFor-File 
{
	param
	(	
		[String] $Type = "Open",
		[String] $Title = "Select File",
		[String] $Filename = $null,
		[String[]] $FileTypes,
		[switch] $RestoreDirectory,
		[IO.DirectoryInfo] $InitialDirectory = $null
	)
	
	[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
	
	if ($FileTypes)
	{
		$FileTypes | % {
			$filter += $_.ToUpper() + " Files|*.$_|"
		}
		$filter = $filter.TrimEnd("|")
	}
	else
	{
		$filter = "All Files|*.*"
	}
	
	switch ($Type)
	{
		"Open" 
		{
			$dialog = New-Object System.Windows.Forms.OpenFileDialog
			$dialog.Multiselect = $false
		}
		"Save"
		{
			$dialog = New-Object System.Windows.Forms.SaveFileDialog
		}
	}
	
	$dialog.FileName = $Filename
	$dialog.Title = $Title
	$dialog.Filter = $filter
	$dialog.RestoreDirectory = $RestoreDirectory
	$dialog.InitialDirectory = $InitialDirectory.Fullname
	$dialog.ShowHelp = $true
	
	if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
	{
		return $dialog.FileName
	}
	else
	{
		return $null
	}
}
