#requires -pssnapin PSEventing -version 1.1
## http://www.codeplex.com/PSEventing/
## ALSO REQUIRES .NET 3.0
# ---------------------------------------------------------------------------
## <Script>
## <Author>
## Joel "Jaykul" Bennett
## </Author>
## <Description>
## Prompts the user for a selection via voice.
## </Description>
## <Usage>
## Get-Speech "Yes","No" "Would you like some cake?" 
## </Usage>
## </Script>
# ---------------------------------------------------------------------------
param([string[]]$choices,[string]$prompt,[switch]$purge)

BEGIN {
   if ($prompt) {
      Write-Output $prompt | &($MyInvocation.InvocationName) $choices
      break;
   } else {
      [Reflection.Assembly]::LoadWithPartialName("System.Speech") | out-null
      $speaker = new System.Speech.Synthesis.SpeechSynthesizer
      $listener = new System.Speech.Recognition.SpeechRecognizer
      
      $_choices = new System.Speech.Recognition.Choices
      foreach($choice in $choices) {
         $_choices.Add($choice)
      }
      $grammar = new System.Speech.Recognition.Grammar (new System.Speech.Recognition.GrammarBuilder $_choices)
      ## Hook up an event handler
      Connect-EventListener grammar SpeechRecognized
      ## And then start the Recognizer
      $listener = new System.Speech.Recognition.SpeechRecognizer
      $listener.LoadGrammar($grammar)
   }
}

PROCESS {
   if($_ -as [string])
   {
      $speaker.SpeakAsync( $_ ) | out-null
   }
   if($grammar)
   {
      $event = Get-Event -Wait
      Write-Output $event.Args.Result
   }
}

END {
   $speaker.Dispose()
   $listener.Dispose()
}
