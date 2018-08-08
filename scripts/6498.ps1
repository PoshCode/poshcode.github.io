function Convert-Umlaut {
  <#
     .NOTES
         Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$Text
  )
  
  begin {}
  process {
    $Text.Replace([String][Char]0xDF, 'ss').Normalize(
      [Text.NormalizationForm]::FormD
    ).ToCharArray() |
    ForEach-Object {$sb = New-Object Text.StringBuilder}{
      if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory(
        $_
      ) -eq [Globalization.UnicodeCategory]::NonSpacingMark) {
        [void]$sb.Append('e')
      } else { [void]$sb.Append($_) }
    }
    $sb.ToString()
  }
  end {}
}
