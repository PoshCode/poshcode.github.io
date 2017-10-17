    # Download Get-WinEventData ... https://gallery.technet.microsoft.com/scriptcenter/Get-WinEventData-Extract-344ad840
        . "\\path\to\Get-WinEventData.ps1"

    # Set up Sysmon as desired
        #http://technet.microsoft.com/en-us/sysinternals/dn798348

    #Use Get-WinEvent and Get-WinEventData to obtain events and extract XML data from them:
        Get-WinEvent -FilterHashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=3} |
            Get-WinEventData |
            select -first 1 -Property *

            <#

                ...
                EventDataUtcTime             : 10/8/2014 10:41 PM
                EventDataProcessGuid         : {00000000-A3D1-5435-0000-001094C60700}
                EventDataProcessId           : 5248
                EventDataImage               : C:\Program Files (x86)\Plex\Plex Media Server\PlexDlnaServer.exe
                EventDataUser                : *************\*************
                EventDataProtocol            : tcp
                EventDataInitiated           : false
                EventDataSourceIsIpv6        : false
                EventDataSourceIp            : 127.0.0.1
                EventDataSourceHostname      : *************
                EventDataSourcePort          : 12804
                EventDataSourcePortName      : 
                EventDataDestinationIsIpv6   : false
                EventDataDestinationIp       : 127.0.0.1
                EventDataDestinationHostname : *************
                EventDataDestinationPort     : 12805
                EventDataDestinationPortName : 
                ...

            #>

        # Work with the extracted data as desired:
        Get-WinEvent -FilterHashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=3} | get-wineventdata | ?{$_.EventDataImage -like "*plex*"} |
            select EventDataSourceIP, EventDataDestinationIP 

            <#

                EventDataSourceIp EventDataDestinationIp
                ----------------- ----------------------
                127.0.0.1         127.0.0.1                   
                127.0.0.1         127.0.0.1             
                192.168.1.4       192.168.1.4           
                192.168.1.4       192.168.1.4           
                127.0.0.1         127.0.0.1             
                127.0.0.1         127.0.0.1             
                127.0.0.1         127.0.0.1             
                127.0.0.1         127.0.0.1             
                192.168.1.4       192.168.1.115         
                192.168.1.4       192.168.1.115         
                192.168.1.4       192.168.1.115         

            #>
