function Write-Host {
#.Synopsis
#  Wraps Write-Host with support for indenting based on stack depth.
#.Description
#  This Write-Host cmdlet customizes output. You can indent the text using PadIndent, or indent based on stack depth using AutoIndent or by setting the global variable $WriteHostAutoIndent = $true.
#
#  You can specify the color of text by using the ForegroundColor parameter, and you can specify the background color by using the BackgroundColor parameter. The Separator parameter lets you specify a string to use to separate displayed objects. The particular result depends on the program that is hosting Windows PowerShell.
#.Example
#  write-host "no newline test >" -nonewline
#  no newline test >C:\PS>
#
#  This command displays the input to the console, but because of the NoNewline parameter, the output is followed directly by the prompt.
#.Example
#  C:\PS> write-host (2,4,6,8,10,12) -Separator ", -> " -foregroundcolor DarkGreen -backgroundcolor white
#  2, -> 4, -> 6, -> 8, -> 10, -> 12
#
#  This command displays the even numbers from 2 through 12. The Separator parameter is used to add the string , -> (comma, space, -, >, space).
#.Example
#  write-host "Red on white text." -ForegroundColor red -BackgroundColor white
#  Red on white text.
#
#  This command displays the string "Red on white text." The text is red, as defined by the ForegroundColor parameter. The background is white, as defined by the BackgroundColor parameter.
#.Example
#  $WriteHostAutoIndent = $true
#  C:\PS>&{
#  >> Write-Host "Level 1"
#  >> &{ Write-Host "Level 2" 
#  >> &{ Write-Host "Level 3" } 
#  >> Write-Host "Level 2"
#  >> } }
#    Level 1
#      Level 2
#        Level 3
#      Level 2
#
#  This command displays how you can set WriteHostAutoIndent to control the output of a series of nested functions that use Write-Host for logging...
#.Inputs
#  System.Object
#  You can pipe objects to be written to the host
#.Outputs
#  None
#  Write-Host sends objects to the host. It does not return any objects. However, the host might display the objects that Write-Host sends to it.
[CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113426', RemotingCapability='None')]
param(
   # Objects to display in the console.
   [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
   [System.Object[]]
   ${Object},

   # Specifies that the content displayed in the console does not end with a newline character.
   [switch]
   ${NoNewline},

   # String to the output between objects displayed on the console.
   [System.Object]
   ${Separator},

   # Specifies the text color. There is no default.
   [System.ConsoleColor]
   ${ForegroundColor},

   # Specifies the background color. There is no default
   [System.ConsoleColor]
   ${BackgroundColor},

   # If set, Write-Host will indent based on the stack depth.  Defaults to the global preference variable $WriteHostAutoIndent (False).
   [Switch]
   $AutoIndent = $(if($Global:WriteHostAutoIndent){$Global:WriteHostAutoIndent}else{$False}),
   
   # Amount to indent (before auto indent).  Defaults to the global preference variable $WriteHostPadIndent (0).
   [Int]
   $PadIndent = $(if($Global:WriteHostPadIndent){$Global:WriteHostPadIndent}else{0}),

   # Number of spaces in each indent. Defaults to the global preference variable WriteHostIndentSize (2).
   [Int]
   $IndentSize = $(if($Global:WriteHostIndentSize){$Global:WriteHostIndentSize}else{2})
)
begin
{
   function Get-ScopeDepth { 
      $depth = 0
      trap { continue } # trap outside the do-while scope
      do { $null = Get-Variable PID -Scope (++$depth) } while($?)
      return $depth - 3
   }
   
   if($PSBoundParameters.ContainsKey("AutoIndent")) { $null = $PSBoundParameters.Remove("AutoIndent") }
   if($PSBoundParameters.ContainsKey("PadIndent"))  { $null = $PSBoundParameters.Remove("PadIndent")  }
   if($PSBoundParameters.ContainsKey("IndentSize")) { $null = $PSBoundParameters.Remove("IndentSize") }
   
   $Indent = $PadIndent
   
   if($AutoIndent) { $Indent += (Get-ScopeDepth) * $IndentSize }
   $Width = $Host.Ui.RawUI.BufferSize.Width - $Indent

   if($PSBoundParameters.ContainsKey("Object")) {
      $OFS = $Separator
      $PSBoundParameters["Object"] = $(
         foreach($line in $Object) {
            $line = "$line".Trim("`n").Trim("`r")
            for($start = 0; $start -lt $line.Length; $start += $Width -1) {
               $Count = if($Width -gt ($Line.Length - $start)) { $Line.Length - $start} else { $Width - 1}
               (" " * $Indent) + $line.SubString($start,$Count).Trim()
            }
         }
      ) -join ${Separator}
   }
   
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Host', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
      $OFS = $Separator
      $_ = $(
         foreach($line in $_) {
            $line = "$line".Trim("`n").Trim("`r")
            for($start = 0; $start -lt $line.Length; $start += $Width -1) {
               $Count = if($Width -gt ($Line.Length - $start)) { $Line.Length - $start} else { $Width - 1}
               (" " * $Indent) + $line.SubString($start,$Count).Trim()
            }
         }
      ) -join ${Separator}
      $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
}


function Write-Verbose {
#.Synopsis
#  Wraps Write-Verbose with support for indenting based on stack depth. Writes text to the verbose message stream. 
#.Description
#  This Write-Verbose customizes output. You can indent the text using PadIndent, or indent based on stack depth using AutoIndent or by setting the global variable $WriteHostAutoIndent = $true.
#.Example
#  $VerbosePreference = "Continue"
#  C:\PS>write-verbose "Testing Verbose"
#  VERBOSE: Testing Verbose
#
#  Setting the VerbosePreference causes Write-Verbose output to be displayed in the console
#.Example
#  C:\PS> write-Verbose (2,4,6,8,10,12) -Separator ", -> "
#  VERBOSE: 2, -> 4, -> 6, -> 8, -> 10, -> 12
#
#  This command displays the even numbers from 2 through 12. The Separator parameter is used to add the string , -> (comma, space, -, >, space).
#.Example
#  $WriteVerboseAutoIndent = $true
#  C:\PS>&{
#  >> Write-Verbose "Level 1"
#  >> &{ Write-Verbose "Level 2" 
#  >> &{ Write-Verbose "Level 3" } 
#  >> Write-Verbose "Level 2"
#  >> } }
#  VERBOSE:   Level 1
#  VERBOSE:     Level 2
#  VERBOSE:       Level 3
#  VERBOSE:     Level 2
#
#  This command displays how you can set WriteHostAutoIndent to control the output of a series of nested functions that use Write-Verbose for logging...
#.Inputs
#  System.Object
#  You can pipe objects to be written to the verbose message stream. 
#.Outputs
#  None
#  Write-Verbose sends objects to the verbose message stream. It does not return any objects. However, the host might display the objects if the $VerbosePreference
[CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113429', RemotingCapability='None')]
param(
   # Objects to display in the console.
   [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
   [System.Object[]]
   ${Message},

   # String to the output between objects displayed on the console.
   [System.Object]
   ${Separator},

   # If set, Write-Verbose will indent based on the stack depth.  Defaults to the global preference variable $WriteVerboseAutoIndent (False).
   [Switch]
   $AutoIndent = $(if($Global:WriteVerboseAutoIndent){$Global:WriteVerboseAutoIndent}else{$False}),
   
   # Amount to indent (before auto indent).  Defaults to the global preference variable $WriteVerbosePadIndent (0).
   [Int]
   $PadIndent = $(if($Global:WriteVerbosePadIndent){$Global:WriteVerbosePadIndent}else{0}),

   # Number of spaces in each indent. Defaults to the global preference variable WriteVerboseIndentSize (2).
   [Int]
   $IndentSize = $(if($Global:WriteVerboseIndentSize){$Global:WriteVerboseIndentSize}else{2})
)
begin
{
   function Get-ScopeDepth { 
      $depth = 0
      trap { continue } # trap outside the do-while scope
      do { $null = Get-Variable PID -Scope (++$depth) } while($?)
      return $depth - 3
   }
   
   if($PSBoundParameters.ContainsKey("AutoIndent")) { $null = $PSBoundParameters.Remove("AutoIndent") }
   if($PSBoundParameters.ContainsKey("PadIndent"))  { $null = $PSBoundParameters.Remove("PadIndent")  }
   if($PSBoundParameters.ContainsKey("IndentSize")) { $null = $PSBoundParameters.Remove("IndentSize") }
   if($PSBoundParameters.ContainsKey("Separator")) { $null = $PSBoundParameters.Remove("Separator") }
   
   $Indent = $PadIndent
   
   if($AutoIndent) { $Indent += (Get-ScopeDepth) * $IndentSize }
   $Prefix = "VERBOSE: ".Length
   $Width = $Host.Ui.RawUI.BufferSize.Width - $Indent - $Prefix

   
   if($PSBoundParameters.ContainsKey("Message")) {
      $OFS = $Separator
      $PSBoundParameters["Message"] = $(
         foreach($line in $Message) {
            $line = "$line".Trim("`n").Trim("`r")
            for($start = 0; $start -lt $line.Length; $start += $Width - 1) {
               $Count = if($Width -gt ($Line.Length - $start)) { $Line.Length - $start} else { $Width - 1}
               if($start) { 
                  (" " * ($Indent + $Prefix)) + $line.SubString($start,$Count).Trim()
               } else {
                  (" " * $Indent) + $line.SubString($start,$Count).Trim()
               }
            }
         }
      ) -join "`n"
   }
   
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Verbose', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process
{
    try {
      $OFS = $Separator
      $_ = $(
         foreach($line in $_) {
            $line = "$line".Trim("`n").Trim("`r")
            for($start = 0; $start -lt $line.Length; $start += $Width - 1) {
               $Count = if($Width -gt ($Line.Length - $start)) { $Line.Length - $start} else { $Width - 1}
               if($start) { 
                  (" " * ($Indent + $Prefix)) + $line.SubString($start,$Count).Trim()
               } else {
                  (" " * $Indent) + $line.SubString($start,$Count).Trim()
               }
               
            }
         }
      ) -join "`n"
      $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end
{
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
}
