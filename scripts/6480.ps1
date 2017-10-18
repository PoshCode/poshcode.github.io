function global:prompt {
   $(&{
         # FIRST, make a note if there was an error in the previous command
         $err = !$?

         $e = ([char]27) + "["   # ESC=27 for ANSI sequences
         # Colors:
         $fg__ = "${e}39m"; $bg__ = "${e}49m"  # CLEAR
         $fgDK = "${e}30m"; $bgDK = "${e}40m"  # Black     
         $fgDR = "${e}31m"; $bgDR = "${e}41m"  # DarkRed   
         $fgDG = "${e}32m"; $bgDG = "${e}42m"  # DarkGreen 
         $fgDY = "${e}33m"; $bgDY = "${e}43m"  # DarkYellow
         $fgDB = "${e}34m"; $bgDB = "${e}44m"  # DarkBlue  
         $fgDM = "${e}35m"; $bgDM = "${e}45m"  # DarkMagenta
         $fgDC = "${e}36m"; $bgDC = "${e}46m"  # DarkCyan  
         $fgDW = "${e}37m"; $bgDW = "${e}47m"  # Gray      
         $fgK  = "${e}90m"; $bgK  = "${e}100m" # DarkGray  
         $fgR  = "${e}91m"; $bgR  = "${e}101m" # Red       
         $fgG  = "${e}92m"; $bgG  = "${e}102m" # Green     
         $fgY  = "${e}93m"; $bgY  = "${e}103m" # Yellow    
         $fgB  = "${e}94m"; $bgB  = "${e}104m" # Blue      
         $fgM  = "${e}95m"; $bgM  = "${e}105m" # Magenta   
         $fgC  = "${e}96m"; $bgC  = "${e}106m" # Cyan      
         $fgW  = "${e}97m"; $bgW  = "${e}107m" # White     

         
         # PowerLine font characters
         $SRIGHT = [char]0xe0b0 # Solid, right facing triangle
         $RIGHT = [char]0xe0b1 # right facing triangle
         $SLEFT = [char]0xe0b2 # Solid, right facing triangle
         $LEFT = [char]0xe0b3 # right facing triangle
         $LOCK = [char]0xe0a2 # Padlock
         $BRANCH = [char]0xe0a0 # Branch symbol
         $RAQUO = [char]0x203a # Single right-pointing angle quote ?
         $GEAR = [char]0x2699 # The settings icon, I use it for debug
         $EX = [char]0x27a6 # The X that looks like a checkbox.
         $POWER = [char]0x26a1 # The Power lightning-bolt icon
         $MID = [char]0xB7 # Mid dot (I used to use this for pushd counters)

         # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
         if(get-member -sta -input ([Environment]) CurrentDirectory) {
            [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
         }

         try {
            # Also, put the path in the title ... (don't restrict this to the FileSystem)
            $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix, (Convert-Path $pwd),  $pwd.Provider.Name
         } catch {}

         # Determine what nesting level we are at (if any)
         $Nesting = "$GEAR" * $NestedPromptLevel

         # Generate PUSHD(push-location) Stack level string
         $Stack = (Get-Location -Stack).count

         # I used to use Export-CliXml, but Export-CSV is a lot faster
         # $null = Get-History -Count $PersistentHistoryCount | Export-CSV $ProfileDir\.poshhistory

         # If we can use advanced ANSI sequences, we can do some cool things 
         if($env:ConEmuANSI -eq "ON") {
            $w = [Console]::BufferWidth
            $local:LastCommand = Get-History -Count 1
            $Elapsed = if($global:LastCommand.ID -ne $LastCommand.Id) {
               $global:LastCommand = $local:LastCommand
               $Duration = $LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime
               if($Duration.TotalSeconds -ge 1.0) {
                  "{0:h\:mm\:ss\.ffff}" -f $Duration
               } else {
                  "{0}ms" -f $Duration.TotalMilliseconds
               }
            } else { '' }
            # 11 chars is "hh:mm:ss tt"
            $ElapsedLength = [Math]::Max($Elapsed.Length,12)
            $ElapsedPadding = " " * ($ElapsedLength - $Elapsed.Length)
            $TimeStamp = "{0:h:mm:ss tt}" -f [DateTime]::Now

            "${e}s" # MARK LOCATION
            if($Elapsed) {
               # Go UP one line and write at the end of that ... 
               "${e}1A${e}${w}G${e}${ElapsedLength}D"
               "$fgK$bg__$ElapsedPadding$SLEFT" # DarkGray on Transparent
               "$fgW$bgK$Elapsed" # White on DarkGray
               "${e}u" # RECALL LOCATION
            }
            # Go to the end of the line and write there ...
            "${e}${w}G${e}$($TimeStamp.Length)D"
            "$fgK$bg__$SLEFT" # DarkGray on Transparent
            "$fgW$bgK$TimeStamp" # White on DarkGray
            "${e}u" # RECALL LOCATION
         }

         # Output prompt string
         # Set some colors that I might use in other scripts
         if($err) {
            $fg_ = $fgDR
            $bg_ = $bgDR
         } else {
            $fg_ = $fgDB
            $bg_ = $bgDB
         }

         "$fgDY$bgDY<$fgW$bgDY#$($myinvocation.historyID)${Nesting}"
         if($Stack) {
            "$fgDY$bgK$SRIGHT"
            "$fgW$bgK$RAQUO$Stack" # White on DarkGray
            "$fgK$bg_$SRIGHT" # DarkGray on the prompt color
         } else {
            "$fgDY$bg_$SRIGHT"
         }
         
         "$fgW$bg_$($pwd.Drive.Name):${RIGHT}$(Split-Path $pwd.Path -Leaf)"
         
         if($global:VcsStatusEnabled) {
            # It's worth noting that I have my own PSGit module...
            Write-VcsStatus
         } else {
            "$fg_$bg__$SRIGHT$fgW$bgW#>"
         }
      }) -join ""
}
