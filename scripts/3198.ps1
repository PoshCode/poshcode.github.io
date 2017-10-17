#.Synopsis
#  Sets my favorite prompt function
#.Notes
#  I put the id in my prompt because it's very, very useful.
#
#  Invoke-History and my Expand-Alias and Get-PerformanceHistory all take command history IDs
#  Also, you can tab-complete with "#<id>[Tab]" so .
#  For example, the following commands:
#  r 4
#  ## r is an alias for invoke-history, so this reruns your 4th command
#
#  #6[Tab]
#  ## will tab-complete whatever you typed in your 6th command (now you can edit it)
#
#  Expand-Alias -History 6,8,10 > MyScript.ps1
#  ## generates a script from those history items
#
#  GPH -id 6, 8
#  ## compares the performance of those two commands ...
#
param(
   # Controls how much history we keep in the command log
   [Int]$PersistentHistoryCount = 30,
   # If set, we use a pasteable prompt with <# #> around the prompt info
   [Alias("copy","demo")][Switch]$Pasteable, 
   [Int]$global:MaximumHistoryCount = 2048,
   [ConsoleColor]$global:PromptForeground = "Yellow", 
   [ConsoleColor]$global:ErrorForeground = "Red"
)

# Some stuff goes OUTSIDE the prompt function because it doesn't need re-evaluation

# I set the title in my prompt every time, because I want the current PATH location there,
# rather than in my prompt where it takes up too much space.

# But I want other stuff too. I  calculate an initial prefix for the window title
# The title will show the PowerShell version, user, current path, and whether it's elevated or not
# E.g.:"PoSh3 Jaykul@HuddledMasses (ADMIN) - C:\Your\Path\Here (FileSystem)" 
if(!$global:WindowTitlePrefix) {
   $global:WindowTitlePrefix = "PoSh$($PSVersionTable.PSVersion.Major) ${Env:UserName}@${Env:UserDomain}"
   
   # if you're running "elevated" we want to show that:
   $ENV:PROCESS_ELEVATED = ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
                              new-object Security.Principal.WindowsPrincipal (
                              [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
                           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
   
   if($ENV:PROCESS_ELEVATED) {
      $global:WindowTitlePrefix += " (ADMIN)"
   }
}

## Global first-run (profile or first prompt)
if($MyInvocation.HistoryId -eq 1) {
   $ProfileDir = Split-Path $Profile.CurrentUserAllHosts
   ## Import my history
   Import-CSV $ProfileDir\.poshhistory | Add-History
}


if($Pasteable) {
   # The pasteable prompt starts with "<#PS " and ends with " #>"
   #   so that you can copy-paste with the prompt and it will still run
   function global:prompt {
      # FIRST, make a note if there was an error in the previous command
      $err = !$?
      Write-host "<#PS " -NoNewLine -fore gray

      # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
      [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
      
      try {
         # Also, put the path in the title ... (don't restrict this to the FileSystem)
         $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix,$pwd.Path,$pwd.Provider.Name
      } catch {}
      
      # Determine what nesting level we are at (if any)
      $Nesting = "$([char]0xB7)" * $NestedPromptLevel

      # Generate PUSHD(push-location) Stack level string
      $Stack = "+" * (Get-Location -Stack).count
      
      # I used to use Export-CliXml, but Export-CSV is a lot faster
      $null = Get-History -Count 30 | Export-CSV $ProfileDir\.poshhistory
      # Output prompt string
      # If there's an error, set the prompt foreground to the error color...
      if($err) { $fg = $global:ErrorForeground } else { $fg = $global:PromptForeground }
      # Notice: no angle brackets, makes it easy to paste my buffer to the web
      Write-Host "[${Nesting}$($myinvocation.historyID)${Stack}]" -NoNewLine -Foreground $fg
      Write-host " #>" -NoNewLine -fore gray
      # Hack PowerShell ISE CTP2 (requires 4 characters of output)
      if($Host.Name -match "ISE" -and $PSVersionTable.BuildVersion -eq "6.2.8158.0") {
         return "$("$([char]8288)"*3) " 
      } else {
         return " "
      }
   }
} else {
   function global:prompt {
      # FIRST, make a note if there was an error in the previous command
      $err = !$?

      # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
      [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
      
      try {
         # Also, put the path in the title ... (don't restrict this to the FileSystem)
         $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix,$pwd.Path,$pwd.Provider.Name
      } catch {}
      
      # Determine what nesting level we are at (if any)
      $Nesting = "$([char]0xB7)" * $NestedPromptLevel

      # Generate PUSHD(push-location) Stack level string
      $Stack = "+" * (Get-Location -Stack).count
      
      # I used to use Export-CliXml, but Export-CSV is a lot faster
      $null = Get-History -Count 30 | Export-CSV $ProfileDir\.poshhistory

      # Output prompt string
      # If there's an error, set the prompt foreground to "Red", otherwise, "Yellow"
      if($err) { $fg = $global:ErrorForeground } else { $fg = $global:PromptForeground }
      # Notice: no angle brackets, makes it easy to paste my buffer to the web
      Write-Host "[${Nesting}$($myinvocation.historyID)${Stack}]:" -NoNewLine -Fore $fg   
      # Hack PowerShell ISE CTP2 (requires 4 characters of output)
      if($Host.Name -match "ISE" -and $PSVersionTable.BuildVersion -eq "6.2.8158.0") {
         return "$("$([char]8288)"*3) " 
      } else {
         return " "
      }
   }
}
