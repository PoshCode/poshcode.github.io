function Show-ConsoleMenu {
#.Synopsis
#  Displays a menu in the console and returns the selection
#.Description
#  Displays a numbered list in the console, accepts a typed number from the user, and returns it.
#.Example
#  ls | Show-ConsoleMenu -Title "Please pick a file to delete:" -Passthru | rm -whatif
#
#  Description
#  -----------
#  Creates a menu showing a line for every file, and outputs the selected file.
#.Example
#  if(Test-Path $Profile) {
#     switch(Show-ConsoleMenu "Profile exists:" "Delete it!","Rename it with 01","Abort" -Debug) {
#        0 { rm $Profile -whatif }
#        1 { mv $Profile [IO.Path]::ChangeExtension($Profile,"01.ps1") }
#        2 { return }
#     }
#  }
#
#  Description
#  -----------
#  Shows how to use the return value without the Passthru switch.
#  This example would check if you have a profile, and if you do, would offer you the choice of removing or renaming it.
param(
   # The items to be chosen from
   [Parameter(ValueFromPipeline=$true,Position=2)]
   [Alias("InputObject")]
   [PSObject[]]$Choices,
   # A caption to display before the choices
   [Parameter(Position=1)]
   [Alias("Title")]
   [string]$Caption,
   # A scriptblock expression for formatting the Choices.
   [Parameter(Position=3)]
   [ScriptBlock]$Expression=({$_}),
   # A prompt to display after the choices
   [Alias("Footer")]
   [string]$Prompt,
   # How much to indent the "center" of the selection menu (Defaults to 8)
   [int]$indentLeft=8,
   # If set, Show-ConsoleMenu returns the selected value from $choices, otherwise it returns the index (which is usually easier to use in a switch statement)
   [Switch]$Passthru,
   # If set, this function works with my New-BufferBox script by using Out-Buffer ( http://poshcode.org/2899 )
   [Switch]$UseBufferBox,
   # If set, allows multiple selection (Press Enter to stop selecting more)
   [Switch]$MultiSelect
)
begin {
   $allchoices = New-Object System.Collections.Generic.List[PSObject]
}
process {
   if($choices) {
      $allchoices.AddRange($choices)
   }
}
end {
   $Format = "{0:D1}"; 
   $Digits = ($allchoices.Count + 1).ToString().Length
   $Format = "{0:D${Digits}}" 
   
   # Make a hashtable with keys
   for($i=0; $i -lt $allchoices.Count; $i++) {
      $allchoices[$i] = Add-Member -Input $allchoices[$i] -Type NoteProperty -Name ConsoleMenuKey -Value $($format -f ($i+1)) -Passthru
   }

   Write-Debug "There are $($allChoices.Count) choices, so we'll use $Digits digits"
   # output the menu to the screen
   $menu = $allchoices | Format-Table -HideTableHeader @{E="ConsoleMenuKey";A="Right";W=$indentLeft}, @{E=$Expression;A="Left"} -Force | Out-String
   $menu = $menu.TrimEnd() + "`n" 

   if($UseBufferBox) {
      Out-Buffer ("`n" + (" " * ($indentLeft/2)) + $Caption + "`n")  -ForegroundColor $Host.PrivateData.VerboseForegroundColor  -BackgroundColor $Host.PrivateData.VerboseBackgroundColor
      Out-Buffer $menu
   } else {
      Write-Host ("`n" + (" " * ($indentLeft/2)) + $Caption + "`n")  -ForegroundColor $Host.PrivateData.VerboseForegroundColor  -BackgroundColor $Host.PrivateData.VerboseBackgroundColor
      Write-Host $menu
   }
   
   do {
      if($Prompt) {
         if($UseBufferBox) {
            Out-Buffer $Prompt -ForegroundColor $Host.PrivateData.VerboseForegroundColor  -BackgroundColor $Host.PrivateData.VerboseBackgroundColor
         } else {
            Write-Host $Prompt -ForegroundColor $Host.PrivateData.VerboseForegroundColor  -BackgroundColor $Host.PrivateData.VerboseBackgroundColor
         }
      }      
      # get a choice from the user
      [string]$PreviousKeys=""
      do { 
         $Key = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho").Character
         try { 
            [int][string]$choice = "${PreviousKeys}${Key}"
            $index = $choice - 1
            $PreviousKeys = "${PreviousKeys}${Key}"
            Write-Host $Key -NoNewline
         } catch { 
            ## The "?" causes us to re-show the menu. Useful for long multi-selects, which might scroll off.
            if(63 -eq [int][char]$Key) {
               if($UseBufferBox) {
                  Out-Buffer $menu
               } else {
                  Write-Host $menu
               }
            } elseif(13,27,0 -notcontains [int][char]$Key) {
               $warning = "You must type only numeric characters (hit Esc to exit)"
               if($UseBufferBox) {
                  Out-Buffer $warning -ForegroundColor $Host.PrivateData.WarningForegroundColor -BackgroundColor $Host.PrivateData.WarningBackgroundColor
               } else {
                  Write-Warning $warning
               }
            }
         }
      } while( $PreviousKeys.Length -lt $Digits -and (13,27 -notcontains [int][char]$Key))

      if($PreviousKeys.Length -and $allchoices.Count -gt $index -and $index -ge 0) {
         Write-Host
         if($Passthru) { 
            $allchoices[$index] 
         } else { 
            $choice
         }
      }
   } while($key -ne [char]13 -and $MultiSelect)
}}
