# am I running in 32 bit shell?
if ($pshome -like "*syswow64*") {
	
	write-warning "Restarting script under 64 bit powershell"

	# relaunch this script under 64 bit shell
	# if you want powershell 2.0, add -version 2 *before* -file parameter
	& (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
		(join-path $psscriptroot $myinvocation.mycommand) @args

	# exit 32 bit script
	exit
}

# start of script for 64 bit powershell

write-warning "hello from $pshome"
write-warning "My original arguments $args"

