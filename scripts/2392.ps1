param ($ComputerName,$Port)

$sock = new-object System.Net.Sockets.Socket -ArgumentList $([System.Net.Sockets.AddressFamily]::InterNetwork),$([System.Net.Sockets.SocketType]::Stream),$([System.Net.Sockets.ProtocolType]::Tcp)

try {
    $sock.Connect($ComputerName,$Port)
    $sock.Connected
    $sock.Close()

}
catch {
    $false
}
