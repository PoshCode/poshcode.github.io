#'***********************************************************************
#'* File:				Check-Directory.ps1
#'* Creation Date:		2008/05/30
#'* Author: 			Jacob Hodges (Technology Effect)
#'* Purpose:			Checks to see if an INF File is already in the MDT Workbench.
#'* Usage:				.\Create-DistributionShare.ps1 D:\Drivers
#'* Reference:       
#'*
#'* Revisions:			  0.1   JBH 	Initial Version
#'***********************************************************************
Param
(
    [string]$Location =$(throw "You must specify a directory containing drivers")
)
$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get some code Gens
. "$myDir\LibraryCodeGen.ps1"

#Initialize MDT
[System.Reflection.Assembly]::LoadFile("C:\Program Files\Microsoft Deployment Toolkit\Bin\Microsoft.BDD.ConfigManager.dll") | Out-Null
$manager = [Microsoft.BDD.ConfigManager.Manager]

#Get driver manager
$driverManager=$manager::DriverManager

function Compile-Csharp ([string] $code, $FrameworkVersion="v2.0.50727",[Array]$References)
{
	## Obtains an ICodeCompiler from a CodeDomProvider class. 
    $provider = New-Object Microsoft.CSharp.CSharpCodeProvider 

    ## Get the location for System.Management.Automation DLL 
    $dllName = [PsObject].Assembly.Location
	
	## Configure the compiler parameters 
    $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters 
	
	#Path to Framework Directory
	$framework = Join-Path $env:windir "Microsoft.NET\Framework\$FrameWorkVersion"
	
	$assemblies  = new-object Collections.ArrayList
	$assemblies.AddRange( @("${framework}\System.dll",
	"${framework}\system.windows.forms.dll",
	"${framework}\System.data.dll",
	"${framework}\System.Drawing.dll",
	"${framework}\System.Xml.dll", $dllName))
		
	if ($references.Count -ge 1)
	{
		$assemblies.AddRange($References)
	}
	$compilerParameters.ReferencedAssemblies.AddRange($assemblies) 
    $compilerParameters.IncludeDebugInformation = $true 
    $compilerParameters.GenerateInMemory = $true 
 
    ## Invokes compilation.  
    $compilerResults = $provider.CompileAssemblyFromSource($compilerParameters, $code) 
 
    ## Write any errors if generated.         
    if($compilerResults.Errors.Count -gt 0) 
    { 
        $errorLines = "" 
        foreach($error in $compilerResults.Errors) 
        { 
            $errorLines += "`n`t" + $error.Line + ":`t" + $error.ErrorText 
        } 
        Write-Error $errorLines
	} 
}

#Compile some C# to get .inf info
$txtCode = @'
//***************************************************************************
// ***** Script Header *****
//
// Solution:  Solution Accelerator for Business Desktop Deployment
// File:      InfInfo.cs
//
// Purpose:   Gets information from a driver INF file
//
// Usage:     (See constructor below)
//
// Microsoft Solution Version:  3.0.76
// Microsoft Script Version:    3.0.76
// Customer Build Version:      1.0.0
// Customer Script Version:     1.0.0
//
// Microsoft History:
// 3.0.76 MTN  09/22/2006  Added comment block.
//
// Customer History:
//
// ***** End Header *****
//***************************************************************************

using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace MDTCustom
{
    public class InfInfo
    {
        private const uint INF_STYLE_WIN4 = 2;
        private const uint MAX_INF_STRING_LENGTH = 4096;
        private const string INFSTR_SECT_VERSION = "Version";
        private const string INFSTR_SECT_MFG = "Manufacturer";
        private const string INFSTR_KEY_PROVIDER = "Provider";
        private const string INFSTR_KEY_HARDWARE_CLASS = "Class";
        private const string INFSTR_KEY_HARDWARE_CLASSGUID = "ClassGUID";
        private const string INFSTR_DRIVERVERSION_SECTION = "DriverVer";

        public String Provider;
        public String ClassGUID;
        public String ClassName;
        public String Date;
        public String Version;
        public List<String> Platforms;
        public List<String> OSVersions;
        public List<String> PNPIds;

        struct INFCONTEXT
        {
            IntPtr Inf;
            IntPtr CurrentInf;
            uint Section;
            uint Line;
        }

        public InfInfo(String infPath)
        {
            IntPtr theInf;
            uint errorLine;
            INFCONTEXT context;
            StringBuilder infData = new StringBuilder(Convert.ToInt16(MAX_INF_STRING_LENGTH));
            uint requiredSize;
            Guid theGuid;
            Boolean found;
            String deviceSection = "";
            List<String> suffixList = new List<String>();

            Platforms = new List<String>();
            OSVersions = new List<String>();
            PNPIds = new List<String>();
            
            // Open the INF file

            theInf = SetupOpenInfFile(infPath, 0, INF_STYLE_WIN4, out errorLine);


            // Get the platform and OS version information

            if (SetupFindFirstLine(theInf, INFSTR_SECT_VERSION, INFSTR_KEY_PROVIDER, out context))
            {
                SetupGetStringField(ref context, 1, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                Provider = infData.ToString();

                if (SetupFindFirstLine(theInf, INFSTR_SECT_MFG, null, out context))
                {
                    // Get the name of the section that will have the PNP ID info in it

                    SetupGetStringField(ref context, 1, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                    deviceSection = infData.ToString();


                    // Get the platform and version information

                    uint fieldCount = SetupGetFieldCount(ref context);
                    if (fieldCount == 1)
                    {
                        Platforms.Add("x86");
                    }
                    else
                    {
                        for (uint i = 2; i <= fieldCount; i++)
                        {
                            // Get the platform string and figure out what it is

                            SetupGetStringField(ref context, i, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                            if (!suffixList.Contains(infData.ToString()))
                                suffixList.Add(infData.ToString());
                            if (infData.ToString().IndexOf(".") > 0)
                            {
                                if (!suffixList.Contains(infData.ToString().Substring(0, infData.ToString().IndexOf("."))))
                                    suffixList.Add(infData.ToString().Substring(0, infData.ToString().IndexOf(".")));
                            }

                            string platformToAdd = "";
                            if (infData.ToString().IndexOf("NTx86", StringComparison.OrdinalIgnoreCase) >= 0)
                                platformToAdd = "x86";
                            else if (infData.ToString().IndexOf("NTamd64", StringComparison.OrdinalIgnoreCase) >= 0)
                                platformToAdd = "x64";
                            else if (infData.ToString().IndexOf("NTia64", StringComparison.OrdinalIgnoreCase) >= 0)
                                platformToAdd = "ia64";
                            else if (infData.ToString().IndexOf("NT", StringComparison.OrdinalIgnoreCase) >= 0)
                                platformToAdd = "x86";  // Since specifying just "NT" is valid


                            // Make sure the platform isn't already in the list, then add it.

                            found = false;
                            foreach (String p in Platforms)
                                if (p == platformToAdd)
                                    found = true;
                            if (!found)
                                Platforms.Add(platformToAdd);


                            // See if there is a version suffix

                            if (infData.ToString().IndexOf(".") > 0)
                            {
                                OSVersions.Add(infData.ToString().Substring(infData.ToString().IndexOf(".") + 1));
                            }

                        }

                    }
                }
            }

            // Get the class name

            ClassName = null;
            if (SetupFindFirstLine(theInf, INFSTR_SECT_VERSION, INFSTR_KEY_HARDWARE_CLASSGUID, out context))
            {
                SetupGetStringField(ref context, 1, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                ClassGUID = infData.ToString();

                theGuid = new Guid(infData.ToString());
                if (SetupDiClassNameFromGuid(ref theGuid, infData, MAX_INF_STRING_LENGTH, out requiredSize))
                {
                    ClassName = infData.ToString();
                }
            }
            if (ClassName == null)
            {
                if (SetupFindFirstLine(theInf, INFSTR_SECT_VERSION, INFSTR_KEY_HARDWARE_CLASS, out context))
                {
                    SetupGetStringField(ref context, 1, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                    ClassName = infData.ToString();
                }
            }
            if (ClassName == null)
            {
                if (ClassGUID != null)
                    ClassName = ClassGUID;
                else
                    ClassName = "Unknown";
            }


            // Get the date and version

            if (SetupFindFirstLine(theInf, INFSTR_SECT_VERSION, INFSTR_DRIVERVERSION_SECTION, out context))
            {
                SetupGetStringField(ref context, 1, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                Date = infData.ToString();

                SetupGetStringField(ref context, 2, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                Version = infData.ToString();
            }
            else
            {
                Date = "01/01/1990";
                Version = "0.0";
            }


            // Get the PnP ID information, first for an undecorated section

            if (SetupFindFirstLine(theInf, deviceSection, null, out context))
            {
                // If platforms doesn't include x86, add it since this section only would exist if x86 is supported.

                found = false;
                foreach (String p in Platforms)
                    if (p == "x86")
                        found = true;
                if (!found)
                {
                    Platforms.Add("x86");
                }


                // Get the PnP IDs

                do
                {
                    uint fieldCount = SetupGetFieldCount(ref context);
                    for (uint i = 2; i <= fieldCount; i++)
                    {
                        SetupGetStringField(ref context, i, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                        if (!PNPIds.Contains(infData.ToString()))
                            PNPIds.Add(infData.ToString());
                    }
                }
                while (SetupFindNextLine(ref context, out context));
            }

            // Now try the suffixes

            foreach (String suffix in suffixList)
            {
                if (SetupFindFirstLine(theInf, deviceSection + "." + suffix, null, out context))
                {
                    // Get the PnP IDs

                    do
                    {
                        uint fieldCount = SetupGetFieldCount(ref context);
                        for (uint i = 2; i <= fieldCount; i++)
                        {
                            SetupGetStringField(ref context, i, infData, MAX_INF_STRING_LENGTH, out requiredSize);
                            if (!PNPIds.Contains(infData.ToString()))
                                PNPIds.Add(infData.ToString());
                        }
                    }
                    while (SetupFindNextLine(ref context, out context));
                }
            }

            // Finished, clean up

            SetupCloseInfFile(theInf);

        }


        [DllImport("setupapi.dll", EntryPoint = "SetupOpenInfFileW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern IntPtr SetupOpenInfFile(
            string infFile, uint infClass, uint infStyle, out uint errorLine);

        [DllImport("setupapi.dll", EntryPoint = "SetupCloseInfFile", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern void SetupCloseInfFile(
            IntPtr hInf);

        [DllImport("setupapi.dll", EntryPoint = "SetupFindFirstLineW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool SetupFindFirstLine(
            IntPtr hInf, string section, string key, out INFCONTEXT context);

        [DllImport("setupapi.dll", EntryPoint = "SetupFindNextLine", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool SetupFindNextLine(
            ref INFCONTEXT inContext, out INFCONTEXT outContext);

        [DllImport("setupapi.dll", EntryPoint = "SetupGetStringFieldW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool SetupGetStringField(
            ref INFCONTEXT context, uint index, StringBuilder returnBuffer, uint returnBufferSize, out uint requiredSize);

        [DllImport("setupapi.dll", EntryPoint = "SetupDiClassNameFromGuidW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool SetupDiClassNameFromGuid(
            ref Guid theGuid, StringBuilder returnBuffer, uint returnBufferSize, out uint requiredSize);

        [DllImport("setupapi.dll", EntryPoint = "SetupGetFieldCount", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern uint SetupGetFieldCount(
            ref INFCONTEXT context);

    }
}


'@

######################################################### 
#  Here I leverage one of my favorite features (here-strings) to define 
# the C# code I want to run.  Remember - if you use single quotes - the 
# string is taken literally but if you use double-quotes, we'll do variable 
# expansion.  This can be VERY useful. 
######################################################### 
$code = @'
using System; 
using System.Runtime.InteropServices; 

namespace test 
{ 
    public class Testclass 
    { 
        [DllImport("msvcrt.dll")] 
        public static extern int puts(string c); 
        [DllImport("msvcrt.dll")] 
        internal static extern int _flushall(); 


        public static void Run(string message) 
        { 
            puts(message); 
            _flushall(); 
        } 
    } 


} 
'@


######################################################## 
# So now we compile the code and use .NET object access to run it. 
######################################################## 
#Write-Host "asfdaf"
#compile-CSharp $code
#[Test.TestClass]::Run("Monad ROCKS!")



##compile the code
Compile-Csharp $txtCode

$infInfo = [MDTCustom]::InfInfo("D:\Drivers\DC7100\Modem\LTDFNT.INF")

$infInfo.PNPIds

#Function CheckDirectory($directoryPath)
#{
#	#get all the inf files in this directory
#	$files = Get-ChildItem $directoryPath *.inf
#	
#	#see if we already know about this one and if now create one
#	foreach($currentFile in $files)
#	{
#		$newRow = $false
#		$theItem = Find($currentFile)
#	}
#
#}
#
#
#Function FindInfFile($infFile)
#{
#	
#}
#
