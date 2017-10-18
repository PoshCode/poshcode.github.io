# PowerShell RESTful server by Parul Jain paruljain@hotmail.com
# Version 0.1 April 4th, 2013
# 
# Use to offer services to other programs as a simple alternative to remoting and webservice technologies
# Does not require a webserver such as IIS. Works on its own!
# Single threaded; will process requests in order. If requests take long to execute and hundreds of simultaneous clients are expected
#    code needs to be re-written to create a new job per request (I will create that version in the future) 
# Can return plain text, XML, JSON, HTML, etc. XML and JSON are easy to consume from clients. JSON especially with Javascript, JQuery
# Inspired by PERL Dancer and Python Flask 
# 
# Requires PowerShell v3.0 or better (will work in v2.0 but ConvertTo-Json not available)
# 
# On windows 7, 2008R2 and 2012 run the following command once from an administratively privileged command prompt
# This allows your program to listen on port 8000. You can change the port number per your requirements 
# netsh http add urlacl url=http://+:8000/ user=domain\user

# Start of script
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8000/') # Must exactly match the netsh command above

$listener.Start()
'Listening ...'
while ($true) {
    $context = $listener.GetContext() # blocks until request is received
    $request = $context.Request
    $response = $context.Response
    
    # Equivalent to 'routes' in other frameworks
    if ($request.Url -match '/date$') { # response to http://myServer:8000/date
        $response.ContentType = 'text/plain'
        $message = [System.DateTime]::Now.ToString()
    }
    
    if ($request.Url -match '/date/xml$') { # response to http://myServer:8000/date/xml
        $response.ContentType = 'text/xml'
        $hour = [System.DateTime]::Now.Hour
        $minute = [System.DateTime]::Now.Minute
        $message = "<?xml version=""1.0""?><Time><Hour>$hour</Hour><Minute>$minute</Minute></Time>"
    }

    if ($request.Url -match '/date/json$') { # response to http://myServer:8000/date/json
        $response.ContentType = 'application/json'
        $time = '' | select hour, minute
        $time.hour = [System.DateTime]::Now.Hour
        $time.minute = [System.DateTime]::Now.Minute
        $message = $time | ConvertTo-Json
    }
    
    # This will terminate the script. Remove from production!
    if ($request.Url -match '/end$') { break }

    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    $response.ContentLength64 = $buffer.length
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
}

$listener.Stop() 
