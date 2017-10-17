Set-Alias cal Get-Calendar

function Get-Calendar {
  <#
    .LINK
        Follow me on twitter @gregzakharov
        http://msdn.microsoft.com/en-us/library/System.Globalization.aspx
        Get-Date
  #>
  param(
    [Parameter(Mandatory=$false,
               Position=0,
               ValueFromPipeline=$true)]
    [ValidateRange(1,12)]
    [Int32]$Month = (Get-Date -u %m),
    
    [Parameter(Mandatory=$false,
               Position=1,
               ValueFromPipeline=$true)]
    [ValidateScript({$_ -ge 2000})]
    [Int32]$Year = (Get-Date -u %Y)
  )
  
  begin {
    [Globalization.DatetimeFormatInfo]::CurrentInfo.DayNames | % {$arr = @()}{$arr += $_.Substring(0, 2)}
    $cal = [Globalization.CultureInfo]::CurrentCulture.Calendar
    $dow = [Int32]$cal.GetDayOfWeek([DateTime]([String]$Month + ".1." + [String]$Year))
  }
  process {
    $loc = [Globalization.DatetimeFormatInfo]::CurrentInfo.MonthNames[$Month - 1] + ' ' + $Year
    $loc = [String]((' ' * [Math]::Round((20 - $loc.Length) / 2)) + $loc)
    
    if ($dow -ne 0) {for ($i = 0; $i -lt $dow; $i++) {$arr += '  '}}
    1..$cal.GetDaysInMonth($Year, $Month) | % {
      if ($_.ToString().Length -eq "1") {$arr += ' ' + [String]$_}
      else {$arr += [String]$_}
    }
  }
  end {
    Write-Host $loc
    for ($i = 0; $i -lt $arr.Length; $i+=6) {
      Write-Host $arr[$i..($i + 6)]
      $i++
    }
    ""
  }
}
