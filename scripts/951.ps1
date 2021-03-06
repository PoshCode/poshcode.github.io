#-------------------------------------------------
# Send-HTMLFormattedEmail
#-------------------------------------------------
# Usage:	Used to send an HTML Formatted Email that is based on an XSLT template.
#-------------------------------------------------
function Send-HTMLFormattedEmail{
    param ( [string] $To,
            [string] $ToDisName,
            [string] $BCC,
            [string] $From,
            [string] $FromDisName,
            [string] $Subject,
            [string] $Content,
            [string] $Relay,
            [string] $XSLPath)
    
    try {
        # Load XSL Argument List
        $XSLArg = New-Object System.Xml.Xsl.XsltArgumentList
        $XSLArg.Clear() 
        $XSLArg.AddParam("To", $Null, $ToDisName)
        $XSLArg.AddParam("Content", $Null, $Content)

        # Load Documents
        $BaseXMLDoc = New-Object System.Xml.XmlDocument
        $BaseXMLDoc.LoadXml("<root/>")

        $XSLTrans = New-Object System.Xml.Xsl.XslCompiledTransform
        $XSLTrans.Load($XSLPath)

        #Perform XSL Transform
        $FinalXMLDoc = New-Object System.Xml.XmlDocument
        $MemStream = New-Object System.IO.MemoryStream
     
        $XMLWriter = [System.Xml.XmlWriter]::Create($MemStream)
        $XSLTrans.Transform($BaseXMLDoc, $XSLArg, $XMLWriter)

        $XMLWriter.Flush()
        $MemStream.Position = 0
     
        # Load the results
        $FinalXMLDoc.Load($MemStream) 
        $Body = $FinalXMLDoc.Get_OuterXML()

        # Create from, To, BCC and the message strucures
        $MessFrom = New-Object System.Net.Mail.MailAddress $From, $FromDisName
        $MessTo = New-Object System.Net.Mail.Mailaddress $To
        $MessBCC = New-Object System.Net.Mail.Mailaddress $BCC
        $Message = New-Object System.Net.Mail.MailMessage $MessFrom, $MessTo
        
        # Populate message
        $Message.Subject = $Subject
        $Message.Body    = $Body
        $Message.IsBodyHTML = $True

        # Add BCC
        $Message.BCC.Add($MessBCC)
     
        # Create SMTP Client
        $Client = New-Object System.Net.Mail.SmtpClient $Relay

        # Send The Message
        $Client.Send($Message)
        }  
    catch {
	return $Error[0]
        }   
    }

### XSLT Template Example
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
<xsl:output media-type="xml" omit-xml-declaration="yes" />
    <xsl:param name="To"/>
    <xsl:param name="Content"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>My First Formatted Email</title>
            </head>
            <body>
            <div width="400px">
                <p>Dear <xsl:value-of select="$To" />,</p>
                <p></p>
                <p><xsl:value-of select="$Content" /></p>
                <p></p>
				<p><strong>Please do not respond to this email!</strong><br />
					An automated system sent this email, if any point you have any questions or concerns please open a help desk ticket.</p>
				<p></p>
            <Address>
			Many thanks from your:<br />	
            Really Cool IT Team<br />
            </Address>
        </div>
      </body>
    </html>
    </xsl:template> 
</xsl:stylesheet>
