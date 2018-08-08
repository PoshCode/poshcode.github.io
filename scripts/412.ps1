# Name: zip.ps1
# Author: Shadow
# Created: 05/12/2008
param([string]$zipfilename=$(throw "ZIP archive name needed!"), 
      [string[]]$filetozip=$(throw "Supply the file(s) to compress (wildcards accepted)"))
trap [Exception] {break;}

#empyt zip file contents
$emptyzipfile=80,75,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;

#create a new file with $ZIPFILENAME and copy the above array into it
$fmode = [System.IO.FileMode]::Create;
$zipfile = new-object -type System.IO.FileStream $zipfilename, $fmode;
$zipfile.Write($emptyzipfile,0,22);
$zipfile.Flush();
$zipfile.Close();

#open the new zip file as folder from Windows Shell Application
$shell=new-object -comobject Shell.Application;
$foldername=(ls $zipfile.Name).FullName;
$zipfolder=$shell.Namespace($foldername);

#Iterate  files to zip, copying them to zip folder.
#In the process, the shell compress them
Write-Host "Compressing:";
$filetozip| %{ls $_}| 
    foreach{ 
        ("`t"+$_.fullname);
        $zipfolder.copyhere($_.fullname,20);
        [System.Threading.Thread]::Sleep(250);
    }
$shell=$null;
$zipfolder=$null;
