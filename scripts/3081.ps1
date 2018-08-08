# function Set-HostColor {
param(
[Switch]$Light = $(
                     ## Based on whether we're elevated or not, switch between DARK and LIGHT versions of Solarized:
                     $([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista or higher and ...
                        new-object Security.Principal.WindowsPrincipal ( 
                        # current user is an administrator (Note: ROLE, not GROUP)
                        [Security.Principal.WindowsIdentity]::GetCurrent()) 
                     ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) 
                  )
)

# SOLARIZED HEX        16/8 TERMCOL  XTERM/HEX   L*A*B      RGB         HSB
# --------- -------    ---- -------  ----------- ---------- ----------- -----------
$base03  = "#002b36" #  8/4 brblack  234 #1c1c1c 15 -12 -12   0  43  54 193 100  21
$base02  = "#073642" #  0/4 black    235 #262626 20 -12 -12   7  54  66 192  90  26
$base01  = "#586e75" # 10/7 brgreen  240 #585858 45 -07 -07  88 110 117 194  25  46
$base00  = "#657b83" # 11/7 bryellow 241 #626262 50 -07 -07 101 123 131 195  23  51
$base0   = "#839496" # 12/6 brblue   244 #808080 60 -06 -03 131 148 150 186  13  59
$base1   = "#93a1a1" # 14/4 brcyan   245 #8a8a8a 65 -05 -02 147 161 161 180   9  63
$base2   = "#eee8d5" #  7/7 white    254 #e4e4e4 92 -00  10 238 232 213  44  11  93
$base3   = "#fdf6e3" # 15/7 brwhite  230 #ffffd7 97  00  10 253 246 227  44  10  99
$yellow  = "#b58900" #  3/3 yellow   136 #af8700 60  10  65 181 137   0  45 100  71
$orange  = "#cb4b16" #  9/3 brred    166 #d75f00 50  50  55 203  75  22  18  89  80
$red     = "#dc322f" #  1/1 red      160 #d70000 50  65  45 220  50  47   1  79  86
$magenta = "#d33682" #  5/5 magenta  125 #af005f 50  65 -05 211  54 130 331  74  83
$violet  = "#6c71c4" # 13/5 brmagenta 61 #5f5faf 50  15 -45 108 113 196 237  45  77
$blue    = "#268bd2" #  4/4 blue      33 #0087ff 55 -10 -45  38 139 210 205  82  82
$cyan    = "#2aa198" #  6/6 cyan      37 #00afaf 60 -35 -05  42 161 152 175  74  63
$green   = "#859900" #  2/2 green     64 #5f8700 60 -20  65 133 153   0  68 100  60
## BEGIN SOLARIZING ----------------------------------------------
   if($Host.Name -eq "Windows PowerShell ISE Host" -and $psISE) {
      $psISE.Options.FontName = 'Consolas'
      
      $psISE.Options.TokenColors['Command'] = $yellow
      $psISE.Options.TokenColors['Position'] = $red
      $psISE.Options.TokenColors['GroupEnd'] = $red
      $psISE.Options.TokenColors['GroupStart'] = $red
      $psISE.Options.TokenColors['NewLine'] = '#FFFFFFFF' # not a printable token
      $psISE.Options.TokenColors['String'] = $cyan
      $psISE.Options.TokenColors['Type'] = $orange
      $psISE.Options.TokenColors['Variable'] = $blue
      $psISE.Options.TokenColors['CommandParameter'] = $green
      $psISE.Options.TokenColors['CommandArgument'] = $violet
      $psISE.Options.TokenColors['Number'] = $red

      if ($Light) {
         $psISE.Options.OutputPaneBackgroundColor = $base3
         $psISE.Options.OutputPaneTextBackgroundColor = $base3
         $psISE.Options.OutputPaneForegroundColor = $base00
         $psISE.Options.CommandPaneBackgroundColor = $base3
         $psISE.Options.ScriptPaneBackgroundColor = $base3
         $psISE.Options.TokenColors['Unknown'] = $base00
         $psISE.Options.TokenColors['Member'] = $base00
         $psISE.Options.TokenColors['LineContinuation'] = $base01
         $psISE.Options.TokenColors['StatementSeparator'] = $base01
         $psISE.Options.TokenColors['Comment'] = $base1
         $psISE.Options.TokenColors['Keyword'] = $base01
         $psISE.Options.TokenColors['Attribute'] = $base00
      } else {
         $psISE.Options.OutputPaneBackgroundColor = $base03
         $psISE.Options.OutputPaneTextBackgroundColor = $base03
         $psISE.Options.OutputPaneForegroundColor = $base0
         $psISE.Options.CommandPaneBackgroundColor = $base03
         $psISE.Options.ScriptPaneBackgroundColor = $base03
         $psISE.Options.TokenColors['Unknown'] = $base0
         $psISE.Options.TokenColors['Member'] = $base0
         $psISE.Options.TokenColors['LineContinuation'] = $base1
         $psISE.Options.TokenColors['StatementSeparator'] = $base1
         $psISE.Options.TokenColors['Comment'] = $base01
         $psISE.Options.TokenColors['Keyword'] = $base1
         $psISE.Options.TokenColors['Attribute'] = $base0
      }
      
      $Host.PrivateData.VerboseForegroundColor  = $PSISE.Options.VerboseForegroundColor        = $blue
      $Host.PrivateData.DebugForegroundColor    = $PSISE.Options.DebugForegroundColor          = $green
      $Host.PrivateData.WarningForegroundColor  = $PSISE.Options.WarningForegroundColor        = $orange
      $Host.PrivateData.ErrorForegroundColor    = $PSISE.Options.ErrorForegroundColor          = $red
      $PSISE.Options.OutputPaneForegroundColor  = $base0
      $PSISE.Options.ScriptPaneForegroundColor  = $base0
      
   } elseif($Host.Name -eq "ConsoleHost") {
      ## In the PowerShell Console, we can only use console colors, so we have to pick them by name.
      ## For it to look right, you have to have run PowerShell from a shortcut you've modified with Install-Solarized
      if($Light)
      {
         ## Set the WindowTitlePrefix for my prompt function, so it won't need to test for IsInRole Administrator again.
         # $Host.UI.RawUI.WindowTitle = $global:WindowTitlePrefix = "PoSh ${Env:UserName}@${Env:UserDomain} (ADMIN)"
         $Host.UI.RawUI.BackgroundColor = "White"
         $Host.PrivateData.ProgressBackgroundColor = "Black"
         $Host.UI.RawUI.ForegroundColor = "DarkCyan"
      } else {
         # $Host.UI.RawUI.WindowTitle = $global:WindowTitlePrefix = "PoSh ${Env:UserName}@${Env:UserDomain}"
         $Host.PrivateData.ProgressBackgroundColor = "White"
         $Host.UI.RawUI.BackgroundColor = "Black"
         $Host.UI.RawUI.ForegroundColor = "DarkRed"
      }

      $Host.PrivateData.ErrorForegroundColor    = "Red"
      $Host.PrivateData.WarningForegroundColor  = "DarkYellow"
      $Host.PrivateData.DebugForegroundColor    = "Green"
      $Host.PrivateData.VerboseForegroundColor  = "Blue"
      $Host.PrivateData.ProgressForegroundColor = "Magenta"
      
      $Host.PrivateData.ErrorBackgroundColor    = 
      $Host.PrivateData.WarningBackgroundColor  = 
      $Host.PrivateData.DebugBackgroundColor    = 
      $Host.PrivateData.VerboseBackgroundColor  = 
      $Host.UI.RawUI.BackgroundColor
   }
# }
# Set-HostColor
