function Edit-Function {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
        $Name,
        $Editor = $global:PSEditor.Command,
        $Parameters = $global:PSEditor.Parameters
    )
    process {

        $file = [IO.Path]::GetTempFileName() | Rename-Item -NewName { [IO.Path]::ChangeExtension($_,".tmp.ps1") } -PassThru
        if(Test-Path Function:\$Name) {
            Set-Content $file (Get-Content Function:\$Name)
        }

        if(!$Editor) {
            if(Get-Command Git) { 
                $Editor, $Parameters = (git config core.editor) -replace '^([''"]?)(.*?)\1(\s+(.*?))?$',"`$2$([char]31)`$3" -split ([char]31) } | % { "$_".Trim() } | ? { $_ }
            }
            # fall back to sublime if it's around
            if(!(Get-Command $Editor)) {
                $Editor = Get-ChildItem C:\Program*\* -recurse -filter "sublime_text.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
                $Parameters = "-n -w"
            }

            if(!(Get-Command $Editor)) {
                $Editor = "notepad"
            }

            $global:PSEditor.Command = "$Editor"
            $global:PSEditor.Parameters = "$Parameters"
        }

        Start-Process $Editor $Parameters, $file -Wait

        Set-Content Function:\$Name ([scriptblock]::create((Get-Content $file)))
        Remove-Item $File
    }
}
