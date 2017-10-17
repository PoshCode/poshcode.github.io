function Out-UnixFile
{
    Param(

        [Parameter( Mandatory = $True )]
        [string]
        $FilePath,

        [Parameter( Mandatory = $True, ValueFromPipeline = $True )]
        [string[]]
        $InputObject,

        [switch]
        $Append = $False
    )

    BEGIN
    {
        $Fs = $Null
        $Sw = $Null
        
        Try
        {
            If( -not( Test-Path $FilePath ) )
            {
                $result = New-Item -Path $FilePath -ItemType File -ErrorAction Stop
            }

            $Encoding = New-Object System.Text.UTF8Encoding

            If( $Append )
            {
                $FileMode = [System.IO.FileMode]::Append
            }
            Else
            {
                $FileMode = [System.IO.FileMode]::Open
            }

            $Fs = New-Object -TypeName System.IO.FileStream( $FilePath, $FileMode )
            $Sw = New-Object -TypeName System.IO.StreamWriter( $Fs, $Encoding )
        }
        Catch
        {
            Throw
        }
    }

    PROCESS
    {

        Try
        {
            ForEach( $Line in $InputObject )
            {
                $Sw.Write( "$( $line )`n" )
            }
        }
        Catch
        {
            If( $Sw -ne $Null )
            {
                $Sw.Close()
            }

            If( $Fs -ne $Null )
            {
                $Fs.Close()
            }

            Throw
        }
    }

    END
    {
        $Sw.Close()
        $Fs.Close()
    }
}
