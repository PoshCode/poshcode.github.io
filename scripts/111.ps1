# ---------------------------------------------------------------------------
## <Script>
## <Author>
## Joel "Jaykul" Bennett
## </Author>
## <Description>
## Outputs text as spoken words
## </Description>
## <Usage>
## Out-Speech "Hello World"
## </Usage>
## <Version>2.0</Version>
## </Script>
# ---------------------------------------------------------------------------

param([string]$wavFile, [switch]$wait, [switch]$purge, [switch]$passthru, [string[]]$inputObject)

begin
{  
   if ($args -eq '-?') {
      ''
      'Usage: Out-Speech [[-Collection] <array>]'
      ''
      'Parameters:'
      '    -Collection : A collection of items to speak.'
      '    -?          : Display this usage information'
      '  Switches:'
      '    -wavFile    : Path to a wav file to write output'
      '    -wait       : Wait for the machine to read each item (NOT asynchronous).'
      '    -purge      : Purge all other speech requests before making this call.'
      '    -passthru   : Pass on the input as output.'
      ''
      'Examples:'
      '    PS> Out-Speech "Hello World"'
      '    PS> Select-RandomLine quotes.txt | Out-Speech -wait'
      '    PS> Get-Content "Hitchhiker''s Guide To The Galaxy.txt" | Out-Speech -wav "Hitchiker.wav"'
      ''
      exit
   }
   if ($inputObject) {
      Write-Output $inputObject | &($MyInvocation.InvocationName) $wavFile -wait:$wait -purge:$purge -passthru:$passthru
      break;
   } else {
      [Reflection.Assembly]::LoadWithPartialName("System.Speech") | out-null
      $speaker = new System.Speech.Synthesis.SpeechSynthesizer
      if( $purge ) {
         $speaker.SpeakAsyncCancelAll()
      }
      if( ![string]::IsNullOrEmpty( $wavFile ) ){
         # this is just for your convenience, because you should wait before trying to use the file.
         if(!$wait.IsPresent){$wait =$true} 
         $speaker.SetOutputToWaveFile( $(if( Split-Path $wavFile ) { $wavFile } else { "$pwd\$wavFile" }) )
      }
   }
}

process
{
   if ($_)
   {
      if($wait) {
         $speaker.Speak( ($_ | out-string) )
      } else {
         $speaker.SpeakAsync( ($_ | out-string) )
      }
      if($passthru) { $_ }
   }
}

end {
   if( ![string]::IsNullOrEmpty( $wavFile ) ){
      $speaker.SetOutputToDefaultAudioDevice()
   }
   $speaker.Dispose()
}
