# Demo showing how to connect to VMware Lab Manager.
# Download LabManager.ps1 from http://www.poshcode.org/753.
. .\LabManager.ps1

# Run this command if your Lab Manager's certificate is untrusted but you
# want to connect.
Ignore-SslErrors

# Connect to Lab Manager.
$labManager = Connect-LabManager -server "demo.eng.vmware.com" `
    -credential (get-credential)

# Find out what operations there are.
$labManager | gm | where { $_.MemberType -eq "Method" }

# List all library configurations.
$labManager.ListConfigurations(1)

# Find all machines deployed from any library configuration.
$labManager.ListConfigurations(1) | foreach {
    write-host ("For Configuration " + $_.id + ":")
    $labManager.ListMachines($_.id)
}

# See http://www.vmware.com/pdf/lm30_soap_api_guide.pdf for help on arguments.
