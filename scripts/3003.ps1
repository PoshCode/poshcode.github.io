# Synopsis:
# Windows Script to collect Hardware information on a local system
# And Convert it to a JSON String and Upload that to a CouchDB
# Database


# Requirements:
# -Local Admin Access in Powershell v2
# -SSL(443/TCP) allowed to CouchDB Host
# -Proxy verified and communication to it


Write-Host "
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 _   _ _____      _                 _
| \ | |_   _|    / \   ___ ___  ___| |_
|  \| | | |     / _ \ / __/ __|/ _ \ __|
| |\  | | |    / ___ \\__ \__ \  __/ |_
|_| \_| |_|   /_/   \_\___/___/\___|\__|
                                     
 ___                      _                
|_ _|_ ____   _____ _ __ | |_ ___  _ __ _   _
 | || '_ \ \ / / _ \ '_ \| __/ _ \| '__| | | |
 | || | | \ V /  __/ | | | || (_) | |  | |_| |
|___|_| |_|\_/ \___|_| |_|\__\___/|_|   \__, |
                                        |___/
 
        by   VulcanX
            2011-09-29
                v1.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"


#Adding ConvertTo-JSON function for use later on in script
Filter ConvertTo-JSON {
    Function New-JSONProperty ($name, $value) {
@"
    "$name": $value
"@
    }

    $targetObject = $_
    $jsonProperties = @()
    $properties = $_ | Get-Member -MemberType *property

    ForEach ($property in $properties) {
        #"$($property.Name)=$($targetObject.$($property.Name)) [$($($targetObject.$($property.Name)).GetType())]"
        #(($targetObject.($property.Name)).GetType()).Name

        $value = $targetObject.($property.Name)
        $dataType = (($targetObject.($property.Name)).GetType()).Name

        switch -regex ($dataType) {
            'String'  {$jsonProperties += New-JSONProperty $property.Name "`"$value`""}
            'Int32|Double' {$jsonProperties += New-JSONProperty $property.Name $value}
            'Object\[\]' {
                #$jsonProperties += "`t`"$($property.Name)`": [$($($targetObject.($property.Name)) -join ',')]"
                $str = "`t`"$($property.Name)`": ["
               
                $count = $targetObject.($property.Name).Count
                For($idx=0; $idx -lt $count; $idx++) {
                    $v = $targetObject.($property.Name)[$idx]
                   
                    switch -regex ($v.GetType()) {
                        'String' {$v="`"$v`""}
                    }
                   
                    if($idx+1 -lt $count) {
                        $comma = ","
                    } else {
                        $comma = ""
                    }
                   
                    $str += "$v$($comma)"
                }
               
               
                $jsonProperties += "$str]"
            }
            default {$_}
        }
    }

    "{`r`n $($jsonProperties -join ",`r`n") `r`n}"
}


#Get WMI Info
#Declaring all variables for use later in JSON
$HOSTNAME1 = Get-WmiObject win32_computersystem | Select-Object -ExpandProperty Name
$HOSTNAME2 = Get-WmiObject win32_computersystem | Select-Object -ExpandProperty Domain
$HOSTNAME = "$HOSTNAME1.$HOSTNAME2"
$OS = Get-WmiObject win32_operatingsystem | Select-Object -ExpandProperty Caption
$OS_RELEASE = Get-WmiObject win32_operatingsystem | Select-Object -ExpandProperty Version
$IP_ADDRESS_1 = Get-WmiObject win32_NetworkAdapterConfiguration | Where { $_.IPAddress -and $_.IPAddress -notlike ':' } | Select -ExpandProperty IPAddress
$IP_ADDRESS = $IP_ADDRESS_1 -join ' ' # Adding multiple address onto one line
$MAC_ADDRESS_1 = Get-WmiObject win32_networkadapter | Where { $_.PhysicalAdapter -eq $TRUE -and $_.MacAddress -ne $null } | Select-Object -ExpandProperty MACAddress
$MAC_ADDRESS = $MAC_ADDRESS_1 -join ' ' #Adding multiple addresses onto one line
$MEMORY = Get-WmiObject win32_computersystem | Select-Object -ExpandProperty TotalPhysicalMemory
$BIOS_VENDOR = Get-WmiObject win32_bios | Select-Object -ExpandProperty Manufacturer
$BIOS_VERSION = Get-WmiObject win32_bios | Select-Object -ExpandProperty SMBIOSBIOSVersion
$BIOS_RELEASE_DATE = Get-WmiObject win32_bios | Select-Object @{label='Release Date';expression={$_.ConvertToDateTime($_.releasedate).ToShortDateString()}} | Select-Object -ExpandProperty 'Release Date'
$SYSTEM_MANUFACTURER = Get-WmiObject win32_computersystemproduct | Select-Object -ExpandProperty Vendor
$SYSTEM_PRODUCT_NAME = Get-WmiObject win32_computersystemproduct | Select-Object -ExpandProperty Name
$SYSTEM_VERSION = Get-WmiObject win32_computersystemproduct | Select-Object -ExpandProperty Version
$SYSTEM_SERIAL_NUMBER = Get-WmiObject win32_computersystemproduct | Select-Object -ExpandProperty IdentifyingNumber
$SYSTEM_UUID = Get-WmiObject win32_computersystemproduct | Select-Object -ExpandProperty UUID
$BASEBOARD_MANUFACTURER = Get-WmiObject win32_baseboard | Select-Object -ExpandProperty Manufacturer
$BASEBOARD_PRODUCT_NAME = Get-WmiObject win32_baseboard | Select-Object -ExpandProperty Product
$BASEBOARD_VERSION = Get-WmiObject win32_baseboard | Select-Object -ExpandProperty Version
$BASEBOARD_SERIAL_NUMBER = Get-WmiObject win32_baseboard | Select-Object -ExpandProperty SerialNumber
$BASEBOARD_ASSET_TAG = Get-WmiObject win32_baseboard | Select-Object -ExpandProperty Tag
$CHASSIS_MANUFACTURER = Get-WmiObject win32_systemenclosure | Select-Object -ExpandProperty Manufacturer
$CHASSIS_TYPE = Get-WmiObject win32_systemenclosure | Select-Object -ExpandProperty ChassisTypes
$CHASSIS_VERSION = Get-WmiObject win32_systemenclosure | Select-Object -ExpandProperty Version
$CHASSIS_SERIAL_NUMBER = Get-WmiObject win32_systemenclosure | Select-Object -ExpandProperty SerialNumber
$CHASSIS_ASSET_TAG = Get-WmiObject win32_systemenclosure | Select-Object -ExpandProperty SMBIOSAssetTag
$PROCESSOR_FAMILY = Get-WmiObject win32_processor | Select-Object -ExpandProperty Family
$PROCESSOR_MANUFACTURER = Get-WmiObject win32_processor | Select-Object -ExpandProperty Manufacturer
$PROCESSOR_VERSION = Get-WmiObject win32_processor | Select-Object -ExpandProperty Name
$PROCESSOR_ARCH = Get-WmiObject win32_processor | Select-Object -ExpandProperty Architecture
$PROCESSOR_FREQUENCY = Get-WmiObject win32_processor | Select-Object -ExpandProperty MaxClockSpeed

# Storing all the information in a variable to convert to JSON Later
$RESULTS = (New-Object PSObject |
add-member -pass noteproperty HOSTNAME "$HOSTNAME" |
add-member -pass noteproperty OS "$OS" |
add-member -pass noteproperty OS-RELEASE "$OS_RELEASE" |
add-member -pass noteproperty IP-ADDRESS "$IP_ADDRESS" |
add-member -pass noteproperty MAC-ADDRESS "$MAC_ADDRESS" |
add-member -pass noteproperty MEMORY "$MEMORY" |
add-member -pass noteproperty BIOS-VENDOR "$BIOS_VENDOR" |
add-member -pass noteproperty BIOS-VERSION "$BIOS_VERSION" |
add-member -pass noteproperty BIOS-RELEASE-DATE "$BIOS_RELEASE_DATE" |
add-member -pass noteproperty SYSTEM-MANUFACTURER "$SYSTEM_MANUFACTURER" |
add-member -pass noteproperty SYSTEM-PRODUCT-NAME "$SYSTEM_PRODUCT_NAME" |
add-member -pass noteproperty SYSTEM-VERSION "$SYSTEM_VERSION" |
add-member -pass noteproperty SYSTEM-SERIAL-NUMBER "$SYSTEM_SERIAL_NUMBER" |
add-member -pass noteproperty SYSTEM-UUID "$SYSTEM_UUID" |
add-member -pass noteproperty BASEBOARD-MANUFACTURER "$BASEBOARD_MANUFACTURER" |
add-member -pass noteproperty BASEBOARD-PRODUCT-NAME "$BASEBOARD_PRODUCT_NAME" |
add-member -pass noteproperty BASEBOARD-VERSION "$BASEBOARD_VERSION" |
add-member -pass noteproperty BASEBOARD-SERIAL-NUMBER "$BASEBOARD_SERIAL_NUMBER" |
add-member -pass noteproperty BASEBOARD-ASSET-TAG "$BASEBOARD_ASSET_TAG" |
add-member -pass noteproperty CHASSIS-MANUFACTURER "$CHASSIS_MANUFACTURER" |
add-member -pass noteproperty CHASSIS-TYPE "$CHASSIS_TYPE" |
add-member -pass noteproperty CHASSIS-VERSION "$CHASSIS_VERSION" |
add-member -pass noteproperty CHASSIS-SERIAL-NUMBER "$CHASSIS_SERIAL_NUMBER" |
add-member -pass noteproperty CHASSIS-ASSET-TAG "$CHASSIS_ASSET_TAG" |
add-member -pass noteproperty PROCESSOR-FAMILY "$PROCESSOR_FAMILY" |
add-member -pass noteproperty PROCESSOR-MANUFACTURER "$PROCESSOR_MANUFACTURER" |
add-member -pass noteproperty PROCESSOR-VERSION "$PROCESSOR_VERSION" |
add-member -pass noteproperty PROCESSOR-ARCH "$PROCESSOR_ARCH" |
add-member -pass noteproperty PROCESSOR-FREQUENCY "$PROCESSOR_FREQUENCY" ) | ConvertTo-Json # Converting $RESULTS to JSON Format

# Double check the structure and layout is all correct
echo $RESULTS

# CouchDB Credentials
$username = Read-Host "CouchDB Username"
$password = Read-Host "CouchDB Password"

# Creating the document on the CouchDB Database
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} ; # Accepts all certificates from the host
$request = [System.Net.WebRequest]::Create("https://couchdb-host/database/$HOSTNAME1")

# Converting the Header and adding the username and password to it in base64 encoding
$auth = [System.Text.Encoding]::UTF8.GetBytes("$username" + ":" + "$password")
$base64 = [System.Convert]::ToBase64String($auth)
$authorization = "Authorization: Basic " + $base64
$request.Headers.Add($authorization)

# Adding credentials for the webrequest and address of the proxy
$request.Credentials = New-Object System.Net.NetworkCredential($username, $password)
$request.Proxy = New-Object -TypeName System.Net.WebProxy -ArgumentList "http://randomproxy:8080" # http://*hostname*:*port* format
$data = [Text.Encoding]::UTF8.GetBytes($RESULTS)

# Specifying what method to use
$request.ContentLength = $data.Length
$request.Method = "PUT"

# Be careful to set your content type appropriately...
# This is what you're going to SEND THEM
$request.ContentType = "application/json"; # 'text/xml;charset="utf-8"'; "application/x-www-form-urlencoded"
# This is what you expect back
$request.Accept = "application/json"; # "text/xml"

# Executing the PUT request
$put = new-object IO.StreamWriter $request.GetRequestStream()
$put.Write($data,0,$data.Length)
$put.Flush()
$put.Close()
