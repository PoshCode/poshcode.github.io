Set-Location 'C:\Mirth Connect'
$ChannelOutput=.\mccommand.exe -a https://localhost:38443 -u username -p password -s "C:\commands.txt"

If($ChannelOutput -like '*successfully*')
{
"Channel created successfully and deplyed"
}
else
{
$_.Exception.Message
}


@@ Commands.txt: 
 import "C:\TestServiceChannel1.xml" Force
channel deploy "Channel_name"

