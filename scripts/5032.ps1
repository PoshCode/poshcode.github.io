function Send-ONKYOCommand
{
    [cmdletbinding()]
    param($OnkyoIP,
          [int] $Port = 60128,
          $Command)


    BEGIN {
        # First, lets create a socket
        $Saddrf = [System.Net.Sockets.AddressFamily]::InterNetwork 
        $Stype = [System.Net.Sockets.SocketType]::Stream 
        $Ptype = [System.Net.Sockets.ProtocolType]::TCP
        $Socket = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype 
        $Socket.TTL = 32
    }

    PROCESS {

        # Create the IP address object
        $ReceiverAddress = [System.Net.IPAddress]::Parse($OnkyoIP)

        # Create the IP Endpoint 
        $Endpoint = New-Object System.Net.IPEndPoint $ReceiverAddress, $Port

        # Connect to the reciever
        $Socket.Connect($Endpoint)

        # Lets build the packet

        # Convert the command string to bytes
        $CommandBytes = $Command.ToCharArray() | % { [BYTE]$_ }

        # Calculate the data size
        $CommandLength = $Command.Length + 1

        # Set the header (73,83,67,80 = ISCP)
        $MessageHeader = 73,83,67,80,0,0,0,16,0,0,0,$CommandLength,1,0,0,0

        # Put it all togheter (0x0D = Carriage Return)
        [Byte[]] $Packet = $MessageHeader + $CommandBytes + 0x0D

        # And send it
        $Sent = $Socket.Send($Packet)

        Write-Verbose "Sent $Sent characters to $OnkyoIP on port $Port. The byte array was: $Packet."

        # Let's check the response
        $KeepListening = $true
        $EmptyByteArray = New-Object System.Byte[] 50

        do {
            # Sleep for a while
            Start-Sleep -Milliseconds 50

            # Create a buffer and set the size
            $Buffer = New-Object System.Byte[] 50
            
            # Get the response
            $Response = $Socket.Receive($Buffer)

            # Check if we got something
            if ((Compare-Object $EmptyByteArray $Buffer).length -ne 0) {
                $ConvertedResponse = ($Buffer | % { if ($_ -ne 0) { [CHAR][BYTE]$_ } }) -join ""
                Write-Verbose "Response: $ConvertedResponse"
                $KeepListening = $false
            }

            }
        while ($KeepListening)
    }

    END {
        $Socket.Close()
        $Socket.Dispose()
    }
}
