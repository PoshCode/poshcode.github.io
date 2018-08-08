#requires -version 3

function Get-HelpInfo {

    write-progress -id 1 -Activity "Get-HelpInfo" -Status "Getting remote version table..."

    # could cache this
    $remote = & {
        $html = invoke-webrequest http://technet.microsoft.com/en-us/windowsserver/jj662920
        $html.ParsedHtml.getElementsByTagName("TABLE").item(2).rows| % -begin {
            $total = $html.ParsedHtml.getElementsByTagName("TABLE").item(2).rows.length
            $index = 0
        } -process {
            write-progress -id 1 -Activity "Get-HelpInfo" -Status "Getting remote version table..." `
                -PercentComplete (([float]$index / $total) * 100)
		    ($_.cells | % innertext) -join ","
            $index++
        } | convertfrom-csv
	}

    write-progress -id 1 -Activity "Get-HelpInfo" -Status "Enumerating local modules..." `
        -CurrentOperation "Please wait..."

    # could cache "gmo -list" output too - it's dog slow, and no way to get progress either.
    gmo -list | ? {
        write-progress -id 1 -Activity "Get-HelpInfo" -Status "Examining $($_.name) ..."
        test-path ($info = join-path (split-path $_.path) `
            ("{0}_{1}_HelpInfo.xml" -f $_.name, $_.guid))
    } | % {
        $name = $_.Name
        ([xml](gc $info)).HelpInfo.SupportedUICultures.UICulture
    } | % {
        [pscustomobject]@{
            ModuleName = $name
            UICulture = $_.UICultureName
            Installed = $_.UICultureVersion
            Available = ($remote|? { ($_.modulename -eq $name) -and $_.uiculture `
                -contains $_.uiculturename } ).version
        }
    }
}

get-helpinfo | ft -AutoSize

