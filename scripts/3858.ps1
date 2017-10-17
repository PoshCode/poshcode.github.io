function read-stream ([Parameter(Position=0,Mandatory=$true)][validatenotnull()]
		[System.Net.Sockets.NetworkStream]$stream,
		[String]$expect = "")
{
	$buffer = new-object system.byte[] 1024
	$enc = new-object system.text.asciiEncoding

	## Read all the data available from the stream, writing it to the 
	## screen when done.

	## Allow data to buffer
	start-sleep -m 100
	$output = ""
	while($stream.DataAvailable -or $output -notmatch $expect)
	{   
		$read = $stream.Read($buffer, 0, 1024)    
		$output = "$output$($enc.GetString($buffer, 0, $read))"
		## Allow data to buffer for a bit 
		start-sleep -m 100
	}
	$output.split("`n")
}

function send-command ([parameter(position=0,Mandatory=$true)][validatenotnull()]
		[String]$hostname,
	[parameter(position=1,Mandatory=$true)][validatenotnull()]
		[String]$User,
	[parameter(position=2,Mandatory=$true)][validatenotnull()]
		[String]$Password, 
	[parameter(position=3,Mandatory=$true,valuefrompipeline=$true)][validatenotnull()]
		[String]$InputObject,
		[string]$Expect = "")
{
	begin
	{
		
		$sock = new-object system.net.sockets.tcpclient($hostname,23)
		$str = $sock.GetStream()
		$wrt = new-object system.io.streamwriter($str)
		
		read-stream($str)
		$wrt.writeline($user)
		$wrt.flush()
		read-stream($str)
		$wrt.writeline($password)
		$wrt.flush()
		read-stream($str, $expect)
	}
	process
	{
		$wrt.writeline($InputObject)
		$wrt.flush()
		read-stream($str, $expect)
	}
	end
	{
		$wrt.writeline("exit")
		$wrt.flush()
		read-stream($str)

		## Close the streams 
		$wrt.Close()
		$str.Close()
		$sock.close()
	}
}
