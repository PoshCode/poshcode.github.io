#constants for crypt32.dll methods
[int]$CERT_STORE_PROV_SYSTEM_REGISTRY = 0x0D
[int]$CERT_STORE_OPEN_EXISTING_FLAG = 0x00004000
[int]$CERT_SYSTEM_STORE_SERVICES = 	 0x00050000

$storeTp = $CERT_SYSTEM_STORE_SERVICES + $CERT_STORE_OPEN_EXISTING_FLAG 
$storeProv = $CERT_STORE_PROV_SYSTEM_REGISTRY
$storeName = "STacSV\My"
$certPath = "C:\Users\nschool\Documents\test.pfx"
$pfxPass = ''
$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 
$pfx.import($certPath,$pfxPass,"Exportable,PersistKeySet") 

 $x509HelperSignature = @"
 using System;
 using System.Runtime.InteropServices;
 using System.Security;
 using System.Security.Cryptography;
 using System.Security.Cryptography.X509Certificates;
  
 namespace System
 {
     namespace Security
     {
         namespace Cryptography
         {
             namespace X509Certificates
             {
                 public class Helpers {
                                           
                     [DllImport("crypt32.dll", EntryPoint="CertOpenStore", CharSet=CharSet.Auto, SetLastError=true)]
                     public static extern IntPtr CertOpenStoreStringPara(
                                     int storeProvider,
                                     int encodingType,
                                     IntPtr hcryptProv,
                                     int flags,
                                     String pvPara);
                }
             }
         }
     }
 }
"@


Add-Type $x509HelperSignature
$certStorePt = [System.Security.Cryptography.X509Certificates.Helpers]::CertOpenStoreStringPara($storeProv, 0, 0, $storeTp, $storeName)
$certStore = [System.Security.Cryptography.X509Certificates.X509Store]$certStorePt
$certStore.Certificates | % { if ($_.Subject -match $pfx.subject){$CertStore.Remove($_) }}
$certStore.Add($pfx) 
$certStore.Close() 

