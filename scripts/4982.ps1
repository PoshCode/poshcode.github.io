$Script:PastebinDeveloperKey = 'Put your dev key here'
$Script:PastebinPasteURI     = 'http://pastebin.com/api/api_post.php'
Function Script:EncodeForPost ( [Hashtable]$KeyValues )
{
    @(  
        ForEach ( $KV in $KeyValues.GetEnumerator() )
        {
            "{0}={1}" -f @(
            $KV.Key, $KV.Value | 
            #ForEach-Object { $_ -replace ' ', '+' } | # Pastebin's server doesn't correctly decode these, so don't bother.
            ForEach-Object { [System.Web.HttpUtility]::UrlEncode( $_, [System.Text.Encoding]::UTF8 ) }
            )
        }
    ) -join '&'
}
Function Out-Pastebin
{
    [CmdletBinding()]
    
    Param
    (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [AllowEmptyString()]
        [String[]]
        $InputObject,
        
        [ValidateSet('Public', 'Unlisted', 'Private')]
        [String]
        $Visibility = 'Unlisted',
        
        # Specifies paste language
        [String]
        $Format,
        
        [ValidateSet('N', '10M', '1H', '1D', '1W', '2W', '1M')]
        [String]
        $ExpiresIn = '1D',
        
        [Switch]
        $OpenInBrowser,
        
        [Switch]
        $PassThru
    )
    
    Begin
    {
        Add-Type -AssemblyName System.Web
        
        $Post = [System.Net.HttpWebRequest]::Create( $PastebinPasteURI )
        $Post.Method = "POST"
        $Post.ContentType = "application/x-www-form-urlencoded"
        
        [String[]]$InputText = @()
    }
    
    Process
    {
        ForEach ( $Line in $InputObject )
        {
            $InputText += $Line
        }
    }
    
    End
    {
        $Parameters = @{
            api_dev_key    = $PastebinDeveloperKey;
            api_option     = 'paste';
            api_paste_code  = $InputText -join "`r`n";
            api_paste_name = 'from Out-Pastebin';
            
            api_paste_private = Switch($Visibility) { Public { '0' }; Unlisted { '1' }; Private { '2' }; };
            api_paste_expire_date = $ExpiresIn.ToUpper();
        }
        
        If ( $Format ) { $Parameters[ 'api_paste_format' ] = $Format.ToLower() }
        
        $Content = EncodeForPost $Parameters
        
        $Post.ContentLength = [System.Text.Encoding]::ASCII.GetByteCount( $Content )
        
        $WriteStream = New-Object System.IO.StreamWriter ( $Post.GetRequestStream( ), [System.Text.Encoding]::ASCII )
        $WriteStream.Write( $Content )
        $WriteStream.Close( )
        
        # Send request, get response
        $Response = $Post.GetResponse( )
        $ReadEncoding = [System.Text.Encoding]::GetEncoding( $Response.CharacterSet )
        $ReadStream = New-Object System.IO.StreamReader ( $Response.GetResponseStream( ), $ReadEncoding )
        
        $Result = $ReadStream.ReadToEnd().TrimEnd( )
        
        $ReadStream.Close( )
        $Response.Close( )
        
        If ( $Result.StartsWith( "http" ) )
        {
            If ( $OpenInBrowser )
            {
                Try { [System.Diagnostics.Process]::Start( $Response ) } Catch { }
            }
            Else
            {
                [System.Windows.Forms.Clipboard]::SetText( $Result, 'UnicodeText' )
            }
            
            If ( $PassThru )
            {
                $Result | Write-Output
            }
        }
        Else
        {
            Throw "Error when uploading to pastebin: {0}" -f $Result
        }
    }
}
