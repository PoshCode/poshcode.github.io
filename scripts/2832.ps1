Process {
	# If the computer isn't pingable, move on to next in pipeline.
@@	if ( -not ( SelectAlive $_ ) ) { continue }
