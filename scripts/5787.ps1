function Analyse-Robocopy {
<# 
   .Synopsis 
    This function analyse output logging for robocopy  
   .Description 
    This function analyse output logging for robocopy  
   .Example 
    Analyse-Robocopy -sourcefile d:\robocopy.log -resultfile d:\robocopy-result.log -messages Error
    This command wil generate a new logfile with all Error messages found in sourcefile
   .Example
    Analyse-Robocopy -sourcefile d:\robocopy.log -messages Error
    This command wil generate a new logfile with all Error messages found in sourcefile and place it in C:\temp\Robocopy-Analyse.log
	when the folder C:\Temp not exist the folder will be created
   .Parameter sourcefile 
    The name and location of the file you want to analyse
   .Parameter resultfile
    The location where the result will be saved.
	Default value is c:\Temp\Robocopy-Analyse.log
   .Parameter Messages 
    specify the sort messages you want to find
	Default value is Error
   .Notes 
    NAME:  Analyse-Robocopy
    AUTHOR: Marco van Wyngaarden 
    LASTEDIT: 03/16/2015 14:40 
    KEYWORDS: Robocopy, Analyser
   .Link 
     http://vanwyngaarden.eu/powershell/robocopy-analyser
#> 
	Param(
	[Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)] [string]$sourcefile,
  	$resultfile = "c:\temp\robocopy-Analyse.log",
	[ValidateSet("Error","success")] [String] $messages = "Error"
   )
   
   #check if resultfile is given otherwise fill resultfile with default value
   if ($resultfile -eq "c:\temp\robocopy-Analyse.log"){
    	if (!(Test-Path -Path "c:\temp")){ 
       		New-Item -ItemType directory -Path "c:\temp" | Out-Null
		}
	}	
	#check message type and search logfile
	if ($messages -eq 'Error'){ 
		$output = Get-ChildItem $sourcefile | Select-String -Pattern '(error 123)| (error 32)' 
		$output | Out-File $resultfile -Width 1200
	}
	else{
		$output = Get-ChildItem $sourcefile | Select-String -Pattern '(New File) | (New Dir )' 
		$output | Out-File $resultfile -Width 1200
	}
	Write-Host " ------------------------------------------------"
   	Write-Host " ROBOCOPY LOG ANALYSER "
	Write-Host " ------------------------------------------------"
	Write-Host " "
	Write-Host "" Counted $output.count $messages messages.""
	Write-Host "" Results are saved in $resultfile""
 	Write-Host " "
	Write-Host " ------------------------------------------------"
}

