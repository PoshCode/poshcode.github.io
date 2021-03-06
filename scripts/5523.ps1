Function Write-Console
{
  <#
    .SYNOPSIS
      Writes colored and wrapped messages to the console using Write-Host
    .DESCRIPTION
      Outputs a given message to the console host wrapped at a given character
      count. The wrapping behavior splits at word boundaries to create lines.
      Each line is then padded to the count provided by the Limit parameter so
      that the colored output is consistent length.
    .PARAMETER Message
      [string] The message to write to the console.
    .PARAMETER Limit
      [int] The maximum string length for any given line of text.
    .PARAMETER Type
      [string] Defines what type of message to output (affects coloring).
      Defaults to Success.
      Possible values:
        Error - Dark red background, light red text
        Success - Dark green background, light green text
        Warning - Black background, yellow text
    .INPUTS
      [string] The message to be printed to the screen.
    .OUTPUTS
      None.
    .EXAMPLE
      PS C:\> Write-Console -Message 'This is a really long message that should be split at 30 characters.' -Limit 30
  #>
  param(
    [Parameter(Mandatory=$true)]
    [string] $Message,
    [int] $Limit = 72,
    [ValidateSet('Error','Warning','Success')]
    [string] $Type = 'Success'
  )

  begin
  {
    $SB = New-Object System.Text.StringBuilder
    $Lines = New-Object System.Collections.ArrayList
    $Words = New-Object System.Collections.ArrayList
  }

  process
  {
    # Setup console colors
    switch ($Type)
    {
      'Success' { $FG = 'Green'; $BG = 'DarkGreen' }
      'Error'   { $FG = 'Red'; $BG = 'DarkRed' }
      'Warning' { $FG = 'Yellow'; $BG = 'Black'}
    }
    
    # Split the input string by spaces, then by length.
    $Message -split ' ' | ForEach-Object {
      if ($PSItem.Length -gt $Limit)
      {
        $Split = [math]::Ceiling($PSItem.Length/$Limit)
        $Parts = [regex]::Split($PSitem,$Split,$Limit)
        $Split
        foreach($Part in $Parts)
        {
          $Part
          $null = $Words.Add($Part)
        }
      }
      else
      {
        $null = $Words.Add($PSItem)
      }
    }
    
    $c = $Words.Count
    for ($i=0;$i -le $c;$i++)
    {     
      # Last word/line case
      if ($i -eq $c)
      {
        $Line = $SB.ToString().PadRight($Limit,' ')
        $null = $SB.Clear()
        $null = $Lines.Add($Line)
        $null = $SB.Append("$($Words[$i]) ")
        break;
      }

      # If the current length of SB plus the Word is less than
      # the defined limit, add Word to SB
      if ($SB.Length + ($Words[$i].Length + 1) -le $Limit)
      {
        $null = $SB.Append("$($Words[$i]) ")
      }
      # If the current length of Word puts SB over limit, then
      # pad SB to Limit, add it to the Lines array, clear SB
      # then add the current Word
      else
      {
        $Line = $SB.ToString().PadRight($Limit,' ')
        $null = $SB.Clear()
        $null = $Lines.Add($Line)
        $null = $SB.Append("$($Words[$i]) ")
      }

    }

    foreach ($Line in $Lines)
    {
      Write-Host $Line -ForegroundColor $FG -BackgroundColor $BG
    }
  }

  end
  {
    $SB,$Lines,$Words = $null
  }
}
