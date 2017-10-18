Add-Type @"
 using System;
 using System.Runtime.InteropServices;
 using System.Security;
 using System.Security.Cryptography;
 using System.Security.Cryptography.X509Certificates;
 namespace System
 {namespace Security{namespace Cryptography{namespace X509Certificates{
    public class Helpers {                 
    [DllImport("crypt32.dll", EntryPoint="CertOpenStore", CharSet=CharSet.Auto, SetLastError=true)]
    public static extern IntPtr CertOpenStoreStringPara(
    int storeProvider, int encodingType, IntPtr hcryptProv, int flags, String pvPara);
 }}}}}
"@

Function Update-ServiceCertificate ($Service, $PFXPath, $PFXPass = '') {
    $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 
    $pfx.import($PFXPath,$pfxPass,"Exportable,PersistKeySet") 
    $certStorePt = [System.Security.Cryptography.X509Certificates.Helpers]::CertOpenStoreStringPara(13, 0, 0, 344064, "$Service\My")
    $certStore = [System.Security.Cryptography.X509Certificates.X509Store]$certStorePt
    foreach ($Certificate in $certStore.Certificates) {
            if ($Certificate.Subject -match $pfx.subject){
                write-host "Removing Cert:"
                $Certificate | select FriendlyName, SerialNumber, Thumbprint, Subject, Issuer | fl
                $CertStore.Remove($Certificate) 
                }
        }
    $certStore.Add($pfx) 
    $certStore.Close() 
    }
