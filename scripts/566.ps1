#requires -version 2.0

add-type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace recyclebin
{
    public class Empty
    {
        [DllImport("shell32.dll")]
        static extern int SHEmptyRecycleBin(IntPtr hWnd, string pszRootPath, uint dwFlags);

        public static void EmptyTrash(string RootDrive, uint Flags)
        {
           SHEmptyRecycleBin(IntPtr.Zero, RootDrive, Flags);
        }
    }
}
"@

cmdlet Remove-Trash -snapin CMSchill.RemoveTrash
{
	param(
	[Parameter(Position=0, Mandatory=$false)][string]$Drive = "",
	[switch]$NoConfirmation,
	[switch]$NoProgressGui,
	[switch]$NoSound
	)
	[int]$Flags = 0
	if ( $NoConfirmation ) { $Flags = $Flags -bor 1 }
	if ( $NoProgressGui ) { $Flags = $Flags -bor 2 }
	if ( $NoSound ) { $Flags = $Flags -bor 4 }

	[recyclebin.Empty]::EmptyTrash($RootPath, $Flags)
}
