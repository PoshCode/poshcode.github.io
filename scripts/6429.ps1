#requires -version 2.0
#Does not appear to be working on version 4.0


function Test-Transcribing {
	$externalHost = $host.gettype().getproperty("ExternalHost",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())

	try {
	    $externalHost.gettype().getproperty("IsTranscribing",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($externalHost, @())
	} catch {
             write-warning "This host does not support transcription."
         }
}
