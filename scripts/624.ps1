function New-TrustAllWebClient {
	# Create a compilation environment
	$Provider=New-Object Microsoft.CSharp.CSharpCodeProvider
	$Compiler=$Provider.CreateCompiler()
	$Params=New-Object System.CodeDom.Compiler.CompilerParameters
	$Params.GenerateExecutable=$False
	$Params.GenerateInMemory=$True
	$Params.IncludeDebugInformation=$False
	$Params.ReferencedAssemblies.Add("System.DLL") > $null
	$TASource=@'
	  namespace Local.ToolkitExtensions.Net.CertificatePolicy {
	    public class TrustAll : System.Net.ICertificatePolicy {
	      public TrustAll() { 
	      }
	      public bool CheckValidationResult(System.Net.ServicePoint sp,
	        System.Security.Cryptography.X509Certificates.X509Certificate cert, 
	        System.Net.WebRequest req, int problem) {
	        return true;
	      }
	    }
	  }
'@ 
	$TAResults=$Provider.CompileAssemblyFromSource($Params,$TASource)
	$TAAssembly=$TAResults.CompiledAssembly

	## We now create an instance of the TrustAll and attach it to the ServicePointManager
	$TrustAll=$TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
	[System.Net.ServicePointManager]::CertificatePolicy=$TrustAll

	## The ESX Upload requires the Preauthenticate value to be true which is not the default
	## for the System.Net.WebClient class which has very simple-to-use downloadFile and uploadfile
	## methods.  We create an override class which simply sets that Preauthenticate value.
	## After creating an instance of the Local.ToolkitExtensions.Net.WebClient class, we use it just
	## like the standard WebClient class.
	$WCSource=@'
	  namespace Local.ToolkitExtensions.Net {
	    class WebClient : System.Net.WebClient {
	      protected override System.Net.WebRequest GetWebRequest(System.Uri uri) {
	        System.Net.WebRequest webRequest = base.GetWebRequest(uri);
	        webRequest.PreAuthenticate = true;
	        webRequest.Timeout = 10000;
	        return webRequest;
	      }
	    }
	  }
'@
	$WCResults=$Provider.CompileAssemblyFromSource($Params,$WCSource)
	$WCAssembly=$WCResults.CompiledAssembly

	## Now return the custom WebClient. It behaves almost like a normal WebClient.
	$WebClient=$WCAssembly.CreateInstance("Local.ToolkitExtensions.Net.WebClient")
	return $WebClient
}

# Example of using this function to upload a file over SSL.
# Notice that the object you get back from New-TrustAllWebClient is almost identical
# to what you would get from new-object system.net.webclient.
# $wc = New-TrustAllWebClient
# $credential = get-credential
# $wc.set_Credentials($credential.GetNetworkCredential())
# $URL = "https://192.168.25.129/folder/VM%201/VM%201.vmx?dcPath=ha-datacenter&dsName=datastore1"
# $wc.UploadString($URL, "PUT", "Testing")

