function Import-PfxCertificate {
    #.Synopsis
    #  Import a pfx certificate to the specified local certificate store
    #.Example
    #  Import-PfxCertificate CodeSigning.pfx Cert:\CurrentUser\My
    #
    #  Imports a certificate from a file to the current user's personal cert store
    #.Example
    #  Import-PfxCertificate CodeSigning.pfx Cert:\LocalMachine\TrustedPublisher
    #
    #  Imports a certificate from a file to the machine's trusted publisher store.
    #  Scripts signed by that cert will now be trusted by all users on the machine.    
    [CmdletBinding()]
    param( 
        # The cert file to import: defaults to all .pfx files in the current directory
        [Parameter(ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("PSPath")]
        [String]$PfxCertificatePath = "*.pfx", 
        # The certificate store path
        [Parameter(ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("Target","Store")]
        [String]$CertificateStorePath = "Cert:\CurrentUser\My"
    )

    process {
        $store = Get-Item $CertificateStorePath -EA 0 -EV StoreError | Where { $_ -is [System.Security.Cryptography.X509Certificates.X509Store] }
        if(!$Store) {
            $store = Get-Item Cert:\$CertificateStorePath -EA 0| Where { $_ -is [System.Security.Cryptography.X509Certificates.X509Store] }
            if(!$Store) { throw "Couldn't find X509 Certificate Store: $StoreError" }
            $CertificateStorePath = "Cert:\$CertificateStorePath"
        }

        try {
            $store.Open("MaxAllowed")
        } catch {
            throw "Couldn't open x509 Certificate Store: $_"
        }

        foreach($certFile in Get-Item $PfxCertificatePath) {
            Write-Warning "Attempting to load $($certfile.Name)"
            # Will automatically prompt for password, if the cert is properly protected
            $cert = Get-PfxCertificate -LiteralPath $certFile.FullName
            if(!$cert) {
                Write-Warning "Failed to load $($certfile.Name)"
                continue
            }
            $store.Add($cert)

            Get-Item "${CertificateStorePath}$($cert.Thumbprint)"
        }
        $store.Close()
    }
}


