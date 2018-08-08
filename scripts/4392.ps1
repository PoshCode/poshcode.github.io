function Extract-FiddlerSaz
{
    param([string]$zipfilename)

    if(test-path($zipfilename))
    {	
        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($zipfilename)
        $zipFolder = (Split-Path $zipfilename -Parent) + "\Extracted"

        md $zipFolder

        $zipDestination = $shellApplication.NameSpace($zipFolder)
        
        $zipDestination.CopyHere($zipPackage.Items())

        $rawFolder = Get-ChildItem -Path $zipFolder | where { $_.Name -eq "raw" } | select -First 1

               
        $rawFolder | Get-ChildItem -Filter "*_c.txt" | foreach {

            # here we start picking apart the file
            $sessiondata = $_ | Get-Content

            "PATH: " + ([system.uri](($sessiondata | select -First 1).Split(" ")[1])).PathAndQuery
            $sessiondata | select -Skip 1 -First 1
            echo " "

            # we could take the lines above and append to a CSV file, which you can BULK INSERT into a SQL Database
            $path = ([system.uri](($sessiondata | select -First 1).Split(" ")[1])).PathAndQuery
            $host = ($sessiondata | select -Skip 1 -First 1).Replace("Host: ", "")
            Out-File -InputObject "$path,$host"  -FilePath "c:\fiddlerAnalytics\file.csv" -Append

            # or you can use System.Data.SqlClient and open a connection, create a command, etc.
            # directly from here, and insert your data into your SQL table
            # see the following for a ready to use SQL helper function: http://is.gd/9RxqsM
        }

        # clean up the unzipped folder
        rd $zipFolder -Recurse -Force
        
    }
}
extract-fiddlersaz -zipfilename C:\users\me\Documents\Fiddler2\Captures\test.zip
