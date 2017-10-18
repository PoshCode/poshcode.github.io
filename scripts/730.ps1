## Test-BufferBox 2.0
####################################################################################################
## This script is just a demonstration of some of the things you can do with the buffer
## in the default PowerShell host... it serves as a reminder of how much work remains on
## PoshConsole, and as an inspirations to anyone who is thinking about trying to create
## "interactive" PowerShell applications.
##
## Imagine it's a chat window: you can type, but the whole time, the ongoing conversation in the 
## chat room you have joined is going on in the background.
##
## NOTE: because this is a "chat" demo, we treat your input as text, and to execute script in-line 
## you have to enclose it inside $() braces.
##
####################################################################################################
PARAM(   $title = "PowerShell Interactive Buffer Demo" )

$global:fore  = $Host.UI.RawUI.ForegroundColor
$global:back  = $Host.UI.RawUI.BackgroundColor 

Function New-Box ($Height, $Width, $Title="") {
   $box = &{ "¯¯$Title$('¯'*($Width-($Title.Length+2)))";
            1..($Height - 2) | % {(' ' * $Width)}; 
            ('_' * $Width);
            1..2 | % {(' ' * $Width)}; 
            }
   $boxBuffer = $Host.UI.RawUI.NewBufferCellArray($box,'Green','Black')
   ,$boxBuffer
}

Function Scroll-Buffer ($origin,$Width,$Height,$Scroll=-1){
   $re = new-object $RECT $origin.x, $origin.y, ($origin.x + $width-2), ($origin.y + $height)
   $origin.Y += $Scroll
   $Host.UI.RawUI.ScrollBufferContents($re, $origin, $re, $blank)
}

Function Out-Buffer {
PARAM ($Message, $Foreground = 'White',$Background = 'Black',[switch]$noscroll)
BEGIN {
   if($Message) {
      $Message | Out-Buffer -Fore $Foreground -Back $Background -NoScript:$NoScroll
   }
}
PROCESS { if($_){$Message = $_

   if ( -not $NoScroll) {
      Scroll-Buffer $ContentPos ($WindowSize.Width -2) ($WindowSize.Height - 4)
   }
  
   # "{0},{1} {2},{3} -{4}" -f $script:pos.X, $script:pos.Y, $MessagePos.X, $MessagePos.Y, $message 
   $host.ui.rawui.SetBufferContents(
      $MessagePos,
      $Host.UI.RawUI.NewBufferCellArray( 
         @($message.PadRight($WindowSize.Width)),
         $Foreground,
         $Background)
   )
}}}

Function Clear-Prompt () {
   $Host.UI.RawUI.SetBufferContents( $PromptPos, $prompt )
   $Host.UI.RawUI.CursorPosition = $CursorPos
}

###################################################################################################
##### Initialize a lot of settings
###################################################################################################
   $RECT  = "system.management.automation.host.rectangle"
   $blank = new-object System.Management.Automation.Host.BufferCell(' ','Gray','Black','complete')

   $WindowSize = $Host.UI.RawUI.WindowSize;
   "`n" * $WindowSize.Height
   $ContentPos = $Host.UI.RawUI.WindowPosition;

   $Host.UI.RawUI.ForegroundColor = "Yellow"
   $Host.UI.RawUI.BackgroundColor = "Black"

   $ContentPos.Y += 1 # Keep the title in the top row
   $ContentPos.X += 2 # 2 cell left padding on output
   # The Message is written into the very last line of the ContentBox
   $MessagePos = $ContentPos
   $MessagePos.Y += ($WindowSize.Height - 4)
   
   $PromptPos = $ContentPos
   $PromptPos.X = 0
   $PromptPos.Y += $WindowSize.Height - 2
   $prompt = $Host.UI.RawUI.NewBufferCellArray( @(&{"> "+(" " * ($WindowSize.Width-3))}), "Yellow", "Black")
   $CursorPos = $PromptPos
   $CursorPos.X += 2
###################################################################################################
##### We only need this for the purposes of the demo...
##### In a real script you would, presumably, be getting stuff from somewhere else to display
   $noise = Get-Content ($MyInvocation.MyCommand.Path)
   $index = 0; 
   $random = New-Object "Random"

###################################################################################################
##### The loop starts by clearing the screen ...
$Host.UI.RawUI.SetBufferContents($Host.UI.RawUI.WindowPosition, (New-Box ($WindowSize.Height - 1) $WindowSize.Width $title))
##### Printing a "How to Exit" message
Out-Buffer "  " -Fore DarkGray -Back Cyan
Out-Buffer "     This is just a demo. " -Fore Black -Back Cyan
Out-Buffer "     We will stream in the source code of this script ... " -Fore Black -Back Cyan
Out-Buffer "     And you can type at the bottom while it's running. " -Fore Black -Back Cyan
Out-Buffer "     Imagine this as an n-way chat application like IRC, except that " -Fore Black -Back Cyan
Out-Buffer "  FOR THIS PERFORMANCE ONLY: " -Fore Black -Back Cyan
Out-Buffer "         The part of your chatting friends is played by my source code. " -Fore DarkGray -Back Cyan
Out-Buffer "  " -Fore DarkGray -Back Cyan
Out-Buffer "     Press ESC to exit, or enter 'exit' and hit Enter" -Fore Black -Back Cyan
Out-Buffer "  " -Fore DarkGray -Back Cyan
##### Setting the prompt
Clear-Prompt
##### And initializing our two variables ...
$line=""
$exit = $false
while(!$exit){
   while(!$exit -and $Host.UI.RawUI.KeyAvailable) { 
      $char = $Host.UI.RawUI.ReadKey("IncludeKeyUp,IncludeKeyDown,NoEcho"); 
      # we don't want the key up events, but we do want to get rid of them
      if($char.KeyDown) {
      switch([int]$char.Character) {
         13 { # Enter
               if($line.Trim() -eq "exit") { $exit = $true; break; }
###################################################################################################
###################################################################################################
############# WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING #############
############# This executes the user input!                                           #############
############# Don't use this on, say, content you got from a web page or chat room    #############
            iex "Out-Buffer `"$line`" -Fore Red";                                     #############
###################################################################################################
###################################################################################################
            $line = "";
            Clear-Prompt
         }
         27 { # Esc
            $exit = $true; break;
         }
   	   8 { # Backspace
            if($line.Length -gt 0) {
               $line = $line.SubString(0,$($line.Length-1))
            }
            # $pos = $Host.UI.RawUI.CursorPosition
            $Host.UI.RawUI.SetBufferContents( $PromptPos, $Host.UI.RawUI.NewBufferCellArray( @(&{ "> $($line)$(' ' * ($WindowSize.Width-3-$line.Length))"}), "Yellow", "Black") )
         }
         0 { # Not actually a key
            # Out-Buffer $($Char | Out-String)
         }
         default {
            $line += $char.Character
            $Host.UI.RawUI.SetBufferContents( $PromptPos, $Host.UI.RawUI.NewBufferCellArray( @(&{ "> $($line)$(' ' * ($WindowSize.Width-3-$line.Length))"}), "Yellow", "Black") )
         }
      }
      }
   }
   # Simulate doing useful things 25% of the time
   if($random.NextDouble() -gt 0.75) {
      $noise[($index)..($index++)] | Out-Buffer
      if($index -ge $noise.Length){$index = 0}
   }
   sleep -milli 100
}

# set the colors back ...
$Host.UI.RawUI.ForegroundColor = $fore
$Host.UI.RawUI.BackgroundColor = $back
