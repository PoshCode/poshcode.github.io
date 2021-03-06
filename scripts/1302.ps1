#requires -version 2.0
function New-Shortcut {
<#
.SYNOPSIS
	Creates a new shortcut (.lnk file) pointing at the specified file.

.DESCRIPTION
	The New-Shortcut script creates a shortcut pointing at the target in the location you specify.  You may specify the location as a folder path (which must exist), with a name for the new file (ending in .lnk), or you may specify one of the "SpecialFolder" names like "QuickLaunch" or "CommonDesktop" followed by the name.
	If you specify the path for the link file without a .lnk extension, the path is assumed to be a folder.

.EXAMPLE
	New-Shortcut C:\Windows\Notepad.exe
		Will make a shortcut to notepad in the current folder named "Notepad.lnk"
.EXAMPLE
	New-Shortcut C:\Windows\Notepad.exe QuickLaunch\Editor.lnk -Description "Run Notepad"
		Will make a shortcut to notepad on the QuickLaunch bar with the name "Editor.lnk" and the tooltip "Run Notepad"
.EXAMPLE
	New-Shortcut C:\Windows\Notepad.exe F:\User\
		Will make a shortcut to notepad in the F:\User\ folder with the name "Notepad.lnk"
.NOTE
   Partial dependency on Get-SpecialPath ( https://PoshCode.org/858 )
#>
[CmdletBinding()]
param(
   [Parameter(Position=0,Mandatory=$true)]
	[string]$TargetPath,
	## Put the shortcut where you want: "Special Folder" names allowed!
   [Parameter(Position=1,Mandatory=$true)]
	[string]$LinkPath,
	## Extra parameters for the shortcut
	[string]$Arguments="",
	[string]$WorkingDirectory="",
	[string]$WindowStyle="Normal",
	[string]$IconLocation="",
	[string]$Hotkey="",
	[string]$Description="",
	[string]$Folder=""
)

# Values for Window Style:
# 1 - Normal    -- Activates and displays a window. If the window is minimized or maximized, the system restores it to its original size and position.
# 3 - Maximized -- Activates the window and displays it as a maximized window.
# 7 - Minimized -- Minimizes the window and activates the next top-level window.

if(!(Test-Path $TargetPath) -and !($TargetPath.Contains("://"))) {
   Write-Error "TargetPath must be an existing file for the link to point at (or a URL)"
 	return
}

function New-ShortCutFile {
    param(
		[string]$TargetPath=$(throw "Please specify a TargetPath for link to point to"),
		[string]$LinkPath=$(throw "must pass a path for the shortcut file"),
		[string]$Arguments="",
		[string]$WorkingDirectory=$(Split-Path $TargetPath -parent),
		[string]$WindowStyle="Normal",
		[string]$IconLocation="",
		[string]$Hotkey="",
		[string]$Description=$(Split-Path $TargetPath -Leaf)
	)

	if(-not ($TargetPath.Contains("://") -or (Test-Path (Split-Path (Resolve-Path $TargetPath) -parent)))) {
		Throw "Cannot create Shortcut: Parent folder does not exist"
	}
	if(-not (Test-Path variable:\global:WshShell)) {
		$global:WshShell = New-Object -com "WScript.Shell"
	}


	$Link = $global:WshShell.CreateShortcut($LinkPath)
	$Link.TargetPath = $TargetPath

	[IO.FileInfo]$LinkInfo = $LinkPath

	## Properties for file shortcuts only
	## If the $LinkPath ends in .url you can't set the arguments, icon, etc
	## if you make the same shortcut with a .lnk extension
	## you can still point it at a URL, but you can set hotkeys, icons, etc
	if( $LinkInfo.Extension -ne ".url" ) {
		$Link.WorkingDirectory = $WorkingDirectory
		## Validate $WindowStyle
		if($WindowStyle -is [string]) {
			if( $WindowStyle -like "Normal" ) { $WindowStyle = 1 }
			if( $WindowStyle -like "Maximized" ) { $WindowStyle = 3 }
			if( $WindowStyle -like "Minimized" ) { $WindowStyle = 7 }
		}

		if( $WindowStyle -ne 1 -and $WindowStyle -ne 3 -and $WindowStyle -ne 7) { $WindowStyle = 1 }
		$Link.WindowStyle = $WindowStyle

		if($Hotkey.Length -gt 0 ) { $Link.HotKey = $Hotkey }
		if($Arguments.Length -gt 0 ) { $Link.Arguments = $Arguments }
		if($Description.Length -gt 0 ) { $Link.Description = $Description }
		if($IconLocation.Length -gt 0 ) { $Link.IconLocation = $IconLocation }

	}

  $Link.Save()
	Write-Output (get-item $LinkPath)
}


## If they didn't explicitly specify a folder
if($Folder.Length -eq 0) {
	if($LinkPath.Length -gt 0) {
		$path = Split-Path $LinkPath -parent
		[IO.FileInfo]$LinkInfo = $LinkPath
		if( $LinkInfo.Extension.Length -eq 0 ) {
			$Folder = $LinkPath
		} else {
			# If the LinkPath is just a single word with no \ or extension...
			if($path.Length -eq 0) {
				$Folder = $Pwd
			} else {
				$Folder = $path
			}
		}
	}
	else
	{ $Folder = $Pwd }
}

## If they specified a link path, check it for an extension
if($LinkPath.Length -gt 0) {
	$LinkPath = Split-Path $LinkPath -leaf
	[IO.FileInfo]$LinkInfo = $LinkPath
	if( $LinkInfo.Extension.Length -eq 0 ) {
		# If there's no extension, it must be a folder
		$Folder = $LinkPath
		$LinkPath = ""
	}
}
## If there's no Link name, make one up based on the target
if($LinkPath.Length -eq 0) {
	if($TargetPath.Contains("://")) {
		$LinkPath = "$($TargetPath.split('/')[2]).url"
	} else {
		[IO.FileInfo]$LinkInfo = $TargetPath
		$LinkPath = "$(([IO.FileInfo]$TargetPath).BaseName).lnk"
	}
}

## If the folder doesn't actually exist, maybe it's special...
if( -not (Test-Path $Folder)) {
	$morepath = "";
	if( $Folder.Contains("\") ) {
		$morepath = $Folder.SubString($Folder.IndexOf("\"))
		$Folder = $Folder.SubString(0,$Folder.IndexOf("\"))
	}
	$Folder = Join-Path (Get-SpecialPath $Folder) $morepath
	# or maybe they just screwed up
	trap { throw new-object ArgumentException "Cannot create shortcut: parent folder does not exist" }
}

$LinkPath = (Join-Path $Folder $LinkPath)
New-ShortCutFile $TargetPath $LinkPath $Arguments $WorkingDirectory $WindowStyle $IconLocation $Hotkey $Description
}
