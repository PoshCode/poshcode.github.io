function Set-PrimaryDnsSuffix {
	param ([string] $Suffix)
	
	# http://msdn.microsoft.com/en-us/library/ms724224(v=vs.85).aspx
	$ComputerNamePhysicalDnsDomain = 6
	
	Add-Type -TypeDefinition @"
	using System;
	using System.Runtime.InteropServices;

	namespace ComputerSystem {
	    public class Identification {
	        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
	        static extern bool SetComputerNameEx(int NameType, string lpBuffer);
			
	        public static bool SetPrimaryDnsSuffix(string suffix) {
	            try {
	                return SetComputerNameEx($ComputerNamePhysicalDnsDomain, suffix);
	            }
	            catch (Exception) {
	                return false;
	            }
	        }
	    }
	}
"@
	[ComputerSystem.Identification]::SetPrimaryDnsSuffix($happy.com)
}
