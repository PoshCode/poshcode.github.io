function Time-Stamp
{
    return [System.DateTime]::Now.ToString("yyyy.MM.dd hh:mm:ss");
}

New-Alias -Name ts -Value Time-Stamp;
