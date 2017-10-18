#requires -Module PackageManagement
function Import-NugetLibrary {
    param(
        [Parameter(Mandatory)]
        [String]$Name,

        [String]$Destination = "$(Split-Path $Profile)\Libraries"
    )
    $ErrorActionPreference = "Stop"

    if(!(Test-Path $Destination -Type Container)) {
        throw "The destination path ($Destination) must point to an existing folder, NuGet will install packages in subdirectories of this folder."
    }

    # Normalize: nuget requires destination NOT end with a slash
    $Destination = (Convert-Path $Destination).TrimEnd("\")
    $Package = Install-Package -Name $Name -Destination $Destination -ProviderName NuGet -Source 'https://www.nuget.org/api/v2' -ExcludeVersion -PackageSaveMode nuspec -Force
    $PackagePath = "$Destination\$Name"

    # Nuget packages hide their assemblies in folders with version numbers...
    if($PSVersionTable.PSVersion -ge "4.0") {
        $Versions = "net46","net452","net451","net45","net40","net35","net20"
    }elseif($PSVersionTable.PSVersion -ge "3.0") {
        $Versions = "net40","net35","net20","net45","net451","net452","net46"
    }else {
        $Versions = "net35","net20"
    }

    # build full path with \ on the end
    $LibraryPath = ($Versions -replace "^", "$PackagePath\lib\") + "$PackagePath\lib\" + "$PackagePath"   | 
        # find the first one that exists
        Convert-Path -ErrorAction SilentlyContinue | Select -First 1


    $Number = $LibraryPath -replace '.*?([\d\.]+)','$1' -replace '(?<=\d)(?=\d)','.'


    $References = ([xml](gc "$PackagePath\$Name.nuspec")).package.metadata.references

    # If there's no references node, this is an old package, just reference everything we found
    if(!$References) {
        $Assemblies = Get-ChildItem $LibraryPath -Filter *.dll
    } else {
        $group = $references.Group | where { $_.targetFramework.EndsWith($number) }
        if($group) {
            $Files = $group.reference.File 
        } else {
            # If we can't figure out the right group, just get all the references:
            $Files = @($references.SelectNodes("//*[name(.) = 'reference']").File | Select -Unique)
        }

        $Assemblies = Get-Item ($Files -replace "^", "$LibraryPath\")
    }

    # Just for the purpose of the verbose output
    Push-Location $Destination
    # since we don't know the order, we'll just loop a few times
    for($e=0; $e -lt $Assemblies.Count; $e++) {
        $success = $true
        foreach($assm in $Assemblies) {
            Write-Verbose "Import Library $(Resolve-Path $Assm.FullName -Relative)"
            Add-Type -Path $Assm.FullName -ErrorAction SilentlyContinue -ErrorVariable failure
            if($failure) {
                $success = $false
            } else {
                Write-Host "LOADING: " -Fore Cyan -NoNewline
                Write-Host $LibraryPath\ -Fore Yellow -NoNewline
                Write-Host $Assm.Name -Fore White
            }
        }
        # if we loaded everything ok, we're done
        if($success) { break }
    }
    Pop-Location
    if(!$success) { throw $failure }
    return
}
