#requires -version 2.0

function Test-Transcribing {
	$externalHost = $host.gettype().getproperty("ExternalHost",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())

	try {
	    $consoleHost.gettype().getproperty("IsTranscribing",
		[reflection.bindingflags]"NonPublic,Instance").getvalue($consolehost, @())
	} catch {
             write-warning "This host does not support transcription."
         }
}
