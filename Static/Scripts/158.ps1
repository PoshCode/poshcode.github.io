## Spin-Busy displays a "spinning" character with each step reflecting an individual pipeline object being passed through.
## The current cursor position, fg/bg colors, screen width, etc. can be specified or automatically detected.
##
## This is *very* loosly adapted from Out-Working by Joel Bennett (http://powershellcentral.com/scripts/105).
##
## Parameters:
##   -msWait	Can be specified in order to insert a delay (in ms) after each character is written
##   -spinStr	Can be specified in order to use an alternate set of "spin" characters (see below)
##   -spinChars	Can be specified in order to use an alternate set of "spin" characters (see below)
##   -rawUI		Can be specified if an alternate console window is to be used
##   -bgColor	Can be specified to use a background color different than the current configuration
##   -fgColor	Can be specified to use a foreground color different than the current configuration
##   -curPos	Can be specified to spin in a different location than the current cursor position
##   -startX	Can be specified to start spinning at a different "X" coordinate than the current cursor position
##   -maxX		Can be specified to limit spinning to less than the current window width
##   -trails	Can be used to leave a "trail" of characters to help with longer term waits
##
## If specified, -spinStr is passed as a string of characters with the last 2 characters being the trailing and blank character, respectively.
##   Default: '-\|/. ', spinning '-\|/', trailing with '.' and blanking empty cells with ' ' when complete.
##
## If specified, -spinChars is passed as an array of characters with the last 2 elements being the trailing and blank character, respectively.
##   Default: @('-', '\', '|', '/', '.', ' '), spinning '-\|/', trailing with '.' and blanking empty cells with ' ' when complete.
##
## Examples:
##   $t = (0..1000 | Spin-Busy)
##   $t = (0..1000 | Spin-Busy -trails)
##   $t = (0..1000 | Spin-Busy -mswait 1 -trails)
##   $t = (0..1000 | Spin-Busy -mswait 1 -spinStr "123456789. " -trails)
##   $t = (0..1000 | Spin-Busy 1 -fgColor "Red" -trails)
##   $t = (0..1000 | Spin-Busy 1 -fgColor "Red" -bgColor "Black" -trails)

function Spin-Busy {
	param(
		[Int]														$msWait =		0,
		[String]													$spinStr =		'-\|/. ',
		[Char[]]													$spinChars =	[Char[]] ($spinStr.ToCharArray()),
		[System.Management.Automation.Host.PSHostRawUserInterface]	$rawUI =		(Get-Host).UI.RawUI,
		[ConsoleColor]												$bgColor =		$rawUI.BackgroundColor,
		[ConsoleColor]												$fgColor =		$rawUI.ForegroundColor,
		[System.Management.Automation.Host.Coordinates]				$curPos =		$rawUI.Get_CursorPosition(),
		[Int32]														$startX =		$curPos.X,
		[Int32]														$maxX =			$rawUI.WindowSize.Width,
		[Switch]													$trails
	)

	begin {
		$trailCell =	$rawUI.NewBufferCellArray(@($spinChars[-2]), $fgColor, $bgColor);
		$blankCell =	$rawUI.NewBufferCellArray(@($spinChars[-1]), $fgColor, $bgColor);

		$spinCells =	$spinChars[0..($spinChars.Count - 3)];

		for ($i=0; $i -lt ($spinCells.Count); ++$i) {
			$spinCells[$i] = $rawUI.NewBufferCellArray(@($spinCells[$i]), $fgColor, $bgColor)
		}

		$charNdx =	0;
	}

	process {
		if ($charNdx -lt $spinCells.Count)	{					$rawUI.SetBufferContents($curPos, $spinCells[$charNdx++]);					}
		else								{ $charNdx = 0;		$rawUI.SetBufferContents($curPos, $trailCell);
			if ($trails) {
				if (++$curPos.X -gt $maxX) 	{ do { --$curPos.X;	$rawUI.SetBufferContents($curPos, $blankCell)	} until ($curPos.X -le $startX)	}
			}
		}

		Start-Sleep -milliseconds $msWait
		$_
	}

	end {
		do { $rawUI.SetBufferContents($curPos, $blankCell);	}
		until (--$curPos.X -le $startX)
	}
}

