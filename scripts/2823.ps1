<#################################################################
#          Print Cluster - Printer Comparison                   #
#                                                               #
# This script does a comparison between two print clusters and  #
# looks for differences between the source and destination.  It  #
# has been tested with printer clusters running Server 2003 and #
# 2008.  The prompts will ask for the cluster name and then the #
# resource identifier for the cluster resource.  You'll have to #
# get those yourself or code something in to loop through the   #
# registry and guess.                                           #
#                                                               #
# Note: The script will not report extra printers on the        #
# destination.                                                  #
#                                                               #
#                                       -Alex Stone 7/25/2011   #
#################################################################>


#Set initial variables and collect source server information as well as destination cluster identifier.

#Turns the code interpreter into a syntax Nazi
Set-StrictMode -Version Latest

#Source/Destination Servers and cluster reg keys.
$sserver = Read-Host "Please enter the source server name and press enter:"
$shive = Read-Host "Please enter the cluster resource hive of the source server:"
$dserver = Read-Host "Please enter the destination server name and press enter:"
$dhive = Read-Host "Please enter the cluster resource hive of the destination server:"

#Open remote registries and collect Local Machine key.
$sbase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $sserver)
$dbase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $dserver)

#Store "Printer" subkey for each.
$sprinters = $sbase.OpenSubKey("Cluster").OpenSubKey("Resources").OpenSubKey($shive).OpenSubKey("Parameters").OpenSubKey("Printers")
$dprinters = $dbase.OpenSubKey("Cluster").OpenSubKey("Resources").OpenSubKey($dhive).OpenSubKey("Parameters").OpenSubKey("Printers")


#Outer loop to run through printers on the source.
foreach ($sprnname in $sprinters.GetSubKeyNames())
    {
        #Open each printer subkey and then work store the attributes to be used in the inner loop.
        $sprinter = $sprinters.OpenSubKey($sprnname)
       
            $cname = $sprinter.GetValue("Name")
            $cdriver = $sprinter.GetValue("Printer Driver")
            $cshare = $sprinter.GetValue("Share Name")
            $clocation = $sprinter.GetValue("Location")
            $cproc = $sprinter.GetValue("Print Processor")
            $cport = $sprinter.GetValue("Port")
            
            #Set initial name match to key the rest of the comparisons
            $namematch = $false
                     
                #Inner loop to work through the destination printers.
                foreach ($dprnname in $dprinters.GetSubKeyNames())
                {
                   #Open each printer subkey and then work store the attributes to be used in the inner loop.
                   $dprinter = $dprinters.OpenSubKey($dprnname)
                   
                    $dname = $dprinter.GetValue("Name")
                    $ddriver = $dprinter.GetValue("Printer Driver")
                    $dshare = $dprinter.GetValue("Share Name")
                    $dlocation = $dprinter.GetValue("Location")
                    $dproc = $dprinter.GetValue("Print Processor")
                    $dport = $dprinter.GetValue("Port")
                   
                   #Comparison to determine printer name match.
                   if ($cname -eq $dname) 
                   {
                   
                   #Set the name match flag to true.
                   $namematch = $true
                   
                   #Set initial boolean values to false.
                   $drivermatch = $false
                   $sharematch = $false
                   $locmatch = $false
                   $procmatch = $false
                   $portmatch = $false
                   
                        #Because of name match execute remaining comparisons.
                        
                            #Driver comparison - This is a very basic comparison that counts the total number of words in the drivers names from each server.
                            #It then determines which is longer and loops through that one and looks for matches with the other.  It creates a running count of the matches.
                            #If the number of matches divided into the total number of words results in a ratio of .7 or higher, it considers it a match.  The ratio can be adjusted below.
                            $cdrivera = $cdriver.split(" ")
                            $ddrivera = $ddriver.split(" ")
                            $drvtot = $cdrivera.count + $ddrivera.count
                            $drvscore = 0
                            if ($cdrivera.count -ge $ddrivera.count) {$longdrive = $cdrivera } else {$longdrive = $ddrivera}
                            if ($cdrivera.count -ge $ddrivera.count) {$shortdrive = $ddrivera } else {$shortdrive = $cdrivera}
                            
                            for ($i=0; $i -le $longdrive.count; $i++)
                            {
                                for ($c=0; $c -le $shortdrive.count; $c++)
                                {
                                    if ($longdrive[$i] -match $shortdrive[$c]) {$drvscore++}
                                }
                                
                            }
                            
                            if (($drvscore*2)/($drvtot) -ge .7) {$drivermatch = $true}
                            
                            
                            #Share Name Comparison
                            if ($cshare -eq $dshare) {$sharematch = $true}
                            
                            #Location Comparison
                            if ($clocation -eq $dlocation) {$locmatch = $true}
                            
                            #Processor Comparison
                            if ($cproc -eq $dproc) {$procmatch = $true}
                            
                            #Port Match
                            if ($cport -match "IP_") {$cport = $cport.Substring(3,$cport.Length-3)}
                            if ($dport -match "IP_") {$dport = $dport.Substring(3,$dport.Length-3)}
                            if ($cport -eq $dport) {$portmatch = $true}
                           
                   
                        }
                }
                #Output line.  If we didn't find a matching printer let the user know otherwise present the comparison results.
                if ($namematch -eq $false) {$cname + " is missing from the destination!"} else {$cname+" Driver: "+$drivermatch+"  Share: "+$sharematch+"  Location: "+$locmatch+"  Processor: "+$procmatch+"  Port: "+$portmatch}
                
                #Reset name match flag.
                $namematch = $false
            
            
        
     }
