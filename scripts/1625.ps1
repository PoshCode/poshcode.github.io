   function Send-FTP {
      Param(
         $Server = "ilncenter.net"
      ,  $Credentials = $(Get-Credential)
      ,  [Parameter(ValueFromPipeline=$true)]
         $LocalFile
      ,  $Path = "/"
      ,  $RemoteFile = $(Split-Path $LocalFile -Leaf)
      ,  $ParentProgressId = -1 ## Just ignore this ;)
      ,  $ProgressActivity = "Uploading $LocalFile"
      )
      Process {
         ## Assert the existence of the file in question
         if( -not (Test-Path $LocalFile) ) {
            Throw "File '$LocalFile' does not exist!"
         }

         ## Create the server string (and make sure it uses forward slashes and ftp://)
         $upload = "ftp://" + $Server + ( Join-Path (Join-Path "/" $Path) $RemoteFile ) -replace "\\", "/"
         #$Upload = $upload
         $total = (gci $LocalFile).Length

         Write-Debug $upload
         ## Create FTP request
         $request = [Net.FtpWebRequest]::Create($upload)

         ## NOTE: we do not create a folder here...
         # [System.Net.WebRequestMethods+Ftp]::MakeDirectory
         $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
         $request.Credentials = $Credentials.GetNetworkCredential()
         $request.UsePassive = $true
         $request.UseBinary = $true
         $request.KeepAlive = $false

         try {
            ## Load the file
            $read = [IO.File]::OpenRead( (Convert-Path $LocalFile) )
            $write = $request.GetRequestStream();
            
            $buffer = new-object byte[] 20KB
            $offset = 0
            $progress = 0

            do {
               $offset = $read.Read($buffer, 0, $buffer.Length)
               $progress += $offset
               $write.Write($buffer, 0, $offset);
               Write-Progress $ProgressActivity "Uploading" -Percent ([int]($progress/$total * 100)) -Parent $ParentProgressId
            } while($offset -gt 0)
        
         } finally {
            Write-Debug "Closing Handles"
            $read.Close()
            $write.Close()
         }
      }
   }
