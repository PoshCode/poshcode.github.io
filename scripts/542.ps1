function Trap-CtrlC {
   ## Stops Ctrl+C from exiting this function
   [console]::TreatControlCAsInput = $true
   ## And you have to check every keystroke to see if it's a Ctrl+C
   ## As far as I can tell, for CtrlC the VirtualKeyCode will be 67 and 
   ## The ControlKeyState will include either "LeftCtrlPressed" or "RightCtrlPressed" 
   ## Either of which will -match "CtrlPressed"
   ## But the simplest thing to do is just compare Character = [char]3
   if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
   {
      throw (new-object ExecutionEngineException "Ctrl+C Pressed")
   }
}

function Test-CtrlCIntercept {
   Trap-CtrlC  # Call Trap-CtrlC right away to turn on TreatControlCAsInput 
   ## Do your work ...
   while($true) { 
      $i = ($i+1)%16
      Trap-CtrlC ## Constantly check ...
      write-host (Get-Date) -fore ([ConsoleColor]$i) -NoNewline
      foreach($sleep in 1..4) {
         Trap-CtrlC ## Constantly check ...
         sleep -milli 500; ## Do a few things ...
         Write-Host "." -fore ([ConsoleColor]$i) -NoNewline
      }
      Write-Host
   }
   
   trap [ExecutionEngineException] { 
      Write-Host "Exiting now, don't try to stop me...." -Background DarkRed
      continue # Be careful to do the right thing here (or just don't do anything)
   }
}



## Another way to do the same thing without an external function ....
## Don't use this way unless your loop is really tight ...
## If you use this and hit CTRL+C right after a timestamp is printed, 
## you'll notice the 2 second delay (compared with above)
function Test-CtrlCIntercept { 
   ## Stops Ctrl+C from exiting this function
   [console]::TreatControlCAsInput = $true
   ## Do your work here ...
   while($true) { 
      $i = ($i+1)%16
      write-host (Get-Date) -fore ([ConsoleColor]$i)
      sleep 2; 
      ## You have to be constantly checking for KeyAvailable
      ## And you have to check every keystroke to see if it's a Ctrl+C
      ## As far as I can tell, for CtrlC the VirtualKeyCode will be 67 and 
      ## The ControlKeyState will include either "LeftCtrlPressed" or "RightCtrlPressed" 
      ## Either of which will -match "CtrlPressed"
      ## But the simplest thing to do is just compare Character = [char]3
      if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
      {
         Write-Host "Exiting now, don't try to stop me...." -Background DarkRed
         break;
      }
   }
}
