Function Read-HostMultiple {
## Dave Johnson 07/09/2013
## Allows Read-Host to gather multiple lines of input and return an array of the strings.
## Type paste input. When done, send the Termininating character on its own.
## Terminating character by default is Ctrl-Z to mimic DOS
## Parameters are Prompt to display at the top. Helpful to indicate the TerminatingChar
## if your end user isn't likely to be familiar with the context.
## TerminatingChar is character to send (on its own) to end the collection.
## Suggest using [Char]xx to set to maintain readability throughout various text editors

 Param
        (
            [parameter(Mandatory=$False)]
            [String[]]
            $Prompt,
			
			[parameter(Mandatory=$False)]
            [Char[]]
			$TerminatingChar
		) 

	If (!$TerminatingChar) { # Set a default value if blank
		$TerminatingChar = [char]26 # Char26 = Ctrl-Z
	}
	$x = ""
	$ReadLines = @()
	If ($Prompt) {Write-Host $Prompt " :"}
	while ($x -ne $TerminatingChar) {
		$x = Read-Host
		if ($x -ne $TerminatingChar) {$ReadLines += $x}
	}
	Return $ReadLines
}
