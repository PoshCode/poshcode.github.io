# Wireless Statistics into object
# Author: Josh Popp
# Put Wireless Stats, like Signal Strengh, BSSID, and Channel into an object

# First just dump the netsh output into $wlanraw 
    $wlanraw = netsh wlan show interface

# Create the object as "empty"
    $objWLAN = "" | Select-Object Name,SSID,BSSID,Channel,ReceiveRate,TransmitRate,Signal

# Populate the object from the output, processing 1 line at a time
    ForEach ($Line in $wlanraw) {
        
    	if ([regex]::IsMatch($Line,"    Name")) {
    		$objWLAN.Name = $Line -Replace "    Name                   : ",""
    		}
               
	if ([regex]::IsMatch($Line,"    SSID")) {
		$objWLAN.SSID = $Line -Replace"    SSID                   : ",""
    	       	}
               
         if ([regex]::IsMatch($Line,"    BSSID")) {
    	 	$objWLAN.BSSID = $Line -Replace"    BSSID                  : ",""
		}
               
	if ([regex]::IsMatch($Line,"    Channel")) {
    	   	$objWLAN.Channel = $Line -replace "    Channel                : ",""
		}
               
	if ([regex]::IsMatch($Line,"    Receive rate")) {
    	   	$objWLAN.ReceiveRate = $Line -replace "    Receive rate \(Mbps\)    : ",""
		}   
               
	if ([regex]::IsMatch($Line,"    Transmit rate")) {
    	   	$objWLAN.TransmitRate = $Line -replace "    Transmit rate \(Mbps\)   : ",""
		}  
               
	if ([regex]::IsMatch($Line,"    Signal")) {
    	   	$objWLAN.Signal = $Line -replace "    Signal                 : ",""
		}
        	}
