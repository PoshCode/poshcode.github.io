function Read-Choice {
#.Synopsis
#  Prompt the user for a choice, and return the (0-based) index of the selected item
#.Parameter Message
#  The question to ask
#.Parameter Choices
#  An array of strings representing the "menu" items, with optional ampersands (&) in them to mark (unique) characters to be used to select each item
#.Parameter DefaultChoice
#  The (0-based) index of the menu item to select by default (defaults to zero).
#.Parameter Title
#  An additional caption that can be displayed (usually above the Message) as part of the prompt
#.Example
#  Read-Choice "WEBPAGE BUILDER MENU"  "Create Webpage","View HTML code","Publish Webpage","Remove Webpage","E&xit"
PARAM([string]$message, [string[]]$choices, [int]$defaultChoice=0, [string]$Title=$null )
   if($choices[0].IndexOf('&') -lt 0) {
      $i = 0; 
      $choices = $choices | ForEach-Object {
         if($_ -notmatch '&.') { "&$i $_" } else { $_ }
         $i++
      }
   }
   $Host.UI.PromptForChoice( $caption, $message, [Management.Automation.Host.ChoiceDescription[]]$choices, $defaultChoice )
}

