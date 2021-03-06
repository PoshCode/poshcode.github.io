# just to know which file is invoked by my profile
write-host "loaded . $($MyInvocation.MyCommand.Path)"

if(!$global:WindowTitlePrefix) {
   # But if you're running "elevated" on vista, we want to show that ...
   if( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
         new-object Security.Principal.WindowsPrincipal (
            [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
   {
		##$Isadmin = $True
		$global:WindowTitlePrefix = "PoSh V2 (CTP3) (ADMIN)"
		#(get-host).UI.RawUI.Backgroundcolor="DarkRed"
        $psise.options.CommandPaneBackground = 'pink'
		clear-host
	} else {
		##$Isadmin = $False
		$global:WindowTitlePrefix = "PoSh V2 (CTP3)"
	}
}

function prompt {
   # FIRST, make a note if there was an error in the previous command
   $err = !$?

   # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
   [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
   # Also, put the path in the title ... (don't restrict this to the FileSystem
   $Host.UI.RawUI.WindowTitle = "{0} - {1}/{2}@{3}" -f $global:WindowTitlePrefix,  $env:USERDOMAIN, $env:USERNAME, $env:COMPUTERNAME
     
   # Determine what nesting level we are at (if any)
   $Nesting = "$([char]0xB7)" * $NestedPromptLevel

   # Generate PUSHD(push-location) Stack level string
   $Stack = "+" * (Get-Location -Stack).count
   
   # my New-Script and Get-PerformanceHistory functions use history IDs
   # So, put the ID of the command in, so we can get/invoke-history easier
   # eg: "r 4" will re-run the command that has [4]: in the prompt
   $nextCommandId = (Get-History -count 1).Id + 1
   # Output prompt string
   # If there's an error, set the prompt foreground to "Red", otherwise, "DarkBlue"
   if($err) { $fg = "Red" } else { $fg = "DarkBlue" }
   # Notice: no angle brackets, makes it easy to paste my buffer to the web
   Write-Host "[${Nesting}${nextCommandId}${Stack}]" -NoNewLine -Fore $fg
#   "{0} - {1}/{2}@{3} {4} ({5})`n" -f $global:WindowTitlePrefix,  $env:USERDOMAIN, $env:USERNAME, $env:COMPUTERNAME, $pwd.Path, $pwd.Provider.Name
   "{0} ({1})`n" -f $pwd.Path, $pwd.Provider.Name
} 

