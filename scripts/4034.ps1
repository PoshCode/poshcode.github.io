function Get-SQLSaturdaySessionList { 
        param(
        [string] $Number =  "111",
        $GetUnscheduled
        )
        $baseUrl = "http://sqlsaturday.com/" + $Number
        $url = $baseUrl + "/schedule.aspx"
        $page = $null  
        try { 
            Write-Verbose "Initiating WebClient" 
            $webclient = New-Object system.net.webclient 
             
            Write-Verbose "Attempting to download from $url" 
            $page = $webclient.DownloadString($url) 
        } 
        catch [Exception] { 
            Write-Error ("Could not download {0}.  The following error was logged:`r`n{1}" -f $url, $error[0]) 
        }  
         
        # We only want to continue if something was downloaded       
        if ($page) { 
                Write-Verbose "Page downloaded" 
        
                if(!$GetUnscheduled){
                        Write-Verbose "Getting Scheduled" 
                        #<td><a href="/viewsession.aspx?sat=94&amp;sessionid=5471">Randy Knight<br><br>But it worked great in Dev!  Performance for Devs<br><br>Level: Beginner</a></td>
                        #<td><a href="/viewsession.aspx?sat=89&sessionid=4942">Adam Jorgensen<br /><br />Zero to Cube<br/ ><br />Level: Intermediate</a></td>
                        $regex = [regex]'href="(?<url>/viewsession.aspx\?sat=\d+\&(?:amp;)?sessionid=\d+)">\s*(?<speaker>[^<]+)<br\s*/?\s*><br\s*/?\s*>(?<title>[^<]+)<br\s*/?\s*><br\s*/?\s*>Level:\s*(?<level>[^<]+)</a>' 
                }
                else{
                        Write-Verbose "Getting Unscheduled" 
                        $regex = [regex]'href="(?<url>/viewsession.aspx\?sat=\d+\&(?:amp;)?sessionid=\d+)">\s*(?<title>[^<]+)</a></td><td>(?<speaker>[^<]+)</td><td>(?<level>[^<]+)</td>' 
                }
                
                $matches = $regex.Matches($page)

                Write-Verbose "Match Count: $($matches.count)"


                $table = New-Object system.Data.DataTable "MyTable"
                $col = New-Object system.Data.DataColumn Title,([string])
                $table.columns.add($col)
                $col = New-Object system.Data.DataColumn Speaker,([string])
                $table.columns.add($col)
                $col = New-Object system.Data.DataColumn Level,([string])
                $table.columns.add($col)
                $col = New-Object system.Data.DataColumn URL,([string])
                $table.columns.add($col)

                $matches | % {$row = $table.NewRow(); $row.URL = $baseUrl + $_.Groups['url']; $row.Title = $_.Groups['title']; $row.Speaker = $_.Groups['speaker'] -replace '[\s\.,]+',' '; $row.Level = $_.Groups['level']; $table.Rows.Add($row) }

                $table
        } 
}

#Get-SQLSaturdaySessionList -Number 111 -GetUnscheduled "YesPlease" | Sort-Object -Property Speaker | Group-Object -Property Speaker
#Get-SQLSaturdaySessionList -Number 111 -GetUnscheduled "YesPlease" | Sort-Object -Property Speaker | Group-Object -Property Level
#Get-SQLSaturdaySessionList -Number 111 | Sort-Object -Property Speaker | Group-Object -Property Speaker;
#Get-SQLSaturdaySessionList -Number 111 | Sort-Object -Property Speaker | Group-Object -Property Speaker | measure
