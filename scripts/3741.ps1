Param (
	[Parameter(ValueFromPipelineByPropertyName=$True,
		HelpMessage='Lotus Domino Server')]
		$ServerName,
	[Parameter(ValueFromPipelineByPropertyName=$True,
		HelpMessage='Lotus Mail Database')]
		$Database,
	[Parameter(ValueFromPipelineByPropertyName=$True,
		HelpMessage='View to Select')]
		$View,
	[Parameter(ValueFromPipelineByPropertyName=$True,
		HelpMessage='Folder to save Attachments to.')]
		$Folder
)
Function Get-Attachments{
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipelineByPropertyName=$True,
			HelpMessage='Lotus Domino Server')]
			$ServerName,
		[Parameter(ValueFromPipelineByPropertyName=$True,
			HelpMessage='Lotus Mail Database')]
			$Database,
		[Parameter(ValueFromPipelineByPropertyName=$True,
			HelpMessage='View to Select')]
			$View,
		[Parameter(ValueFromPipelineByPropertyName=$True,
			HelpMessage='Folder to save Attachments to.')]
			$Folder
	)
	Begin {
		$NotesSession = New-Object -ComObject Lotus.NotesSession
		$NotesSession.Initialize()
	}
	Process {
		$NotesDatabase = $NotesSession.GetDatabase( $ServerName, $Database, 1 )
		$AllViews = $NotesDatabase.Views | Select-Object -ExpandProperty Name
		$dbview = $AllViews | Select-String -Pattern $View
		Foreach ($nview in $dbview) {
			$view = $NotesDatabase.GetView($nview)
			$viewnav = $view.CreateViewNav()
			$docs = $viewnav.GetFirstDocument()
			while ($docs -ne $null){
				$document = $docs.Document
				$docdate = ($document.Created).ToShortDateString()
				$date = (Get-Date).ToShortDateString()
				if ($docdate -eq $date){
					if ($document.HasEmbedded){
						foreach ($itm in $document.Items){
							if ($itm.type -eq 1084){
								$attach = $document.GetItemValue($itm.Name)
								#$attach = $document.GetItemValue('$File')
								$attachment = $document.GetAttachment($attach)
								$atname = $attachment.Source
								if (Get-Item $Folder\$atname){
									$extra = (Get-Date -UFormat "%H.%M.%S").toString()
										$attachment.ExtractFile("$Folder\$extra_$atname")
								}
								$attachment.ExtractFile("$Folder\$atname")
							}
						}
					}
				}
				$docs = $viewnav.GetNextDocument($docs)
			}
		}
	}
	End {}
}
Get-Attachments -ServerName $ServerName -Database $Database -View $View -Folder $Folder

