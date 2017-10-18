function upload-directory {
  param( [string] $server = $( Throw "You must specify an FTP server to logon to."),
	 [string] $dir = $( Throw "You must specify a local directory to upload (ie, C:\Testing\FTPTest\)"),
	 [switch] $overwrite = $false,
	 [System.Management.Automation.PSCredential] $cred = $( Throw "You must provide credentials with which to logon to the FTP server.") ) 
        
  $files = (get-childitem $dir -r)

  foreach ($file in $files) {
    $remfilename = $file.FullName.Replace($dir, "")
    $remfilename = $remfilename.Replace("\", "/")
    if ($file.Attributes.ToString().IndexOf("Directory") -ge 0) {
  	  try
  	  {
      send-ftp -server $server -cred $cred -create $remfilename -overwrite:$overwrite
      }
      catch {} #if the directory already exists, ignore the error
    }
    else {
      send-ftp -server $server -cred $cred -localfile $file.FullName -remotefile $remfilename -overwrite:$overwrite
    } #end ifelse
  } #end foreach

}
