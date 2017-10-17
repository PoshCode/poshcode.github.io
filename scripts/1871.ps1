# function Read-Choice {
[CmdletBinding()]
param(
   [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
   [hashtable[]]$Choices
,
   [Parameter(Mandatory=$False)]
   [string]$Caption = "Please choose!"
,  
   [Parameter(Mandatory=$False)]
   [string]$Message = "Choose one of the following options:"
,  
   [Parameter(Mandatory=$False)]
   [int[]]$Default  = 0
,  
   [Switch]$MultipleChoice
,
   [Switch]$Passthru
)
begin {
   [System.Collections.DictionaryEntry[]]$choices = $choices | % { $_.GetEnumerator() }
}
process {
   $Descriptions = [System.Management.Automation.Host.ChoiceDescription[]]( $(
                     foreach($choice in $choices) {
                        New-Object System.Management.Automation.Host.ChoiceDescription $choice.Key,$choice.Value
                     } 
                   ) )

   if(!$MultipleChoice) { [int]$Default = $Default[0] }

   [int[]]$Answer = $Host.UI.PromptForChoice($Caption,$Message,$Descriptions,$Default)

   if($Passthru) {
      Write-Verbose "$Answer"
      Write-Output  $Descriptions[$Answer]
   } else {
      Write-Output $Answer
   }
}

# }
