function Get-TinyUrl
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory,ValueFromPipeline=$true)]
        [string]
        $Url,

        [ValidateSet('xml','json', 'text')]
        [string]
        $Format = 'text',

        #Provider String List => http://tiny-url.info/open_api.html#provider_list
        [ValidateSet('0_mk', '0l_ro', '2u_lc', '3le_ru', '888_hn', '9mp_com', 'ad_vu', 'b54_in', 'bb-h_me', 'bim_im', 'bit_ly', 'chilp_it', 'clicky_me', 'cmprs_me', 'cort_as', 'crum_bs', 'curt_cc', 'cut_by', 'dfly_pk', 'dft_ba', 'di_gd', 'dlvr_it', 'dok_do', 'doo_ly', 'dssurl_com')]        
        [string]
        $Provider = '0_mk'
    )

    #Use a Proxy if any configured
    $SystemProxy = ([System.Net.WebProxy]::GetDefaultProxy().Address.AbsoluteUri)
    
    #Request API Key => http://tiny-url.info/request_api_key.html
    $TinyUrlApiKey = 'YOUR-APIKEY'
    $TinyUrlApiUrl = 'http://tiny-url.info/api/v1/create'

    #API Documentation => http://tiny-url.info/open_api.html
    $RequestUrl = 'http://tiny-url.info/api/v1/create?apikey={0}&provider={1}&format={2}&url={3}' -f $TinyUrlApiKey, $Provider, $Format, $Url
    Write-Debug $RequestUrl
   Invoke-RestMethod -Uri $RequestUrl -Method Get -Proxy $SystemProxy | Write-Output
}

#'https://msdn.microsoft.com/es-es/library/system.uri(v=vs.110).aspx' | Get-TinyUrl

