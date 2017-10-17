
        function Find-Editor {
            #.Synopsis
            #   Find a simple code editor
            #.Description
            #   Tries to find a text editor based on the PSEditor preference variable, the EDITOR environment variable, or your configuration for git.  As a fallback it searches for Sublime, Notepad++, or Atom, and finally falls back to Notepad. 
            #   
            #   I have deliberately excluded PowerShell_ISE because it is a single-instance app which doesn't support "wait" if it's already running.  That is, if PowerShell_ISE is already running, issuing a command like this will return immediately:
            #   
            #   Start-Process PowerShell_ISE $Profile -Wait
            [CmdletBinding()]
            param
            (
                # Specifies a code editor. If the editor is in the Path environment variable (Get-Command <editor>), you can enter just the editor name. Otherwise, enter the path to the executable file for the editor.
                # Defaults to the value of $PSEditor.Command or $PSEditor or Env:Editor if any of them are set.
                [Parameter(Position=1)] 
                [System.String]
                $Editor = $(if($global:PSEditor.Command){ $global:PSEditor.Command } else { $global:PSEditor } ),

                # Specifies commandline parameters for the editor. 
                # Edit-Function.ps1 passes these editor-specific parameters to the editor you select. 
                # For example, sublime uses -n -w to trigger a mode where closing the *tab* will return
                [Parameter(Position=2)]
                [System.String]
                $Parameters = $global:PSEditor.Parameters
            )
            begin {
                function Split-Command {
                    # The normal (unix) "Editor" environment variable can include parameters
                    # so it can be executed from command by just appending the file name.
                    # However, PowerShell can't deal with that, so:
                    param(
                        [Parameter(Mandatory=$true)]
                        [string]$Command
                    )
                    $Parts = @($Command -Split " ")

                    for($count=$Parts.Length; $count -gt 1; $count--) {
                        $Editor = ($Parts[0..$count] -join " ").Trim("'",'"')
                        if((Test-Path $Editor) -and (Get-Command $Editor -ErrorAction SilentlyContinue)) { 
                            $Editor
                            $Parts[$($Count+1)..$($Parts.Length)] -join " "
                            break
                        }
                    }
                }
            }

            end {
                do { # This is the GOTO hack: use break to skip to the end once we find it:
                    # In this test, we let the Get-Command error leak out on purpose
                    if($Editor -and (Get-Command $Editor)) { break }

                    if ($Editor -and !(Get-Command $Editor -ErrorAction SilentlyContinue))
                    {
                        Write-Verbose "Editor is not a valid command, split it:"
                        $Editor, $Parameters = Split-Command $Editor
                        if($Editor) { break }
                    }

                    if (Test-Path Env:Editor)
                    {
                        Write-Verbose "Editor was not passed in, trying Env:Editor"
                        $Editor, $Parameters = Split-Command $Env:Editor
                        if($Editor) { break }
                    }

                    # If no editor is specified, try looking in git config
                    if (Get-Command Git -ErrorAction SilentlyContinue)
                    {
                        Write-Verbose "PSEditor and Env:Editor not found, searching git config"
                        $Editor, $Parameters = Split-Command (git config core.editor)
                        if($Editor) { break }
                    }

                    # Try a few common ones that might be in the path
                    Write-Verbose "Editor not found, trying some others"
                    if($Editor = Get-Command "subl.exe", "sublime_text.exe" | Select-Object -Expand Path -first 1)
                    {
                        $Parameters = "-n -w"
                        break
                    }
                    if($Editor = Get-Command "notepad++.exe" | Select-Object -Expand Path -first 1)
                    {
                        $Parameters = "-multiInst"
                        break
                    }
                    if($Editor = Get-Command "atom.exe" | Select-Object -Expand Path -first 1)
                    {
                        break
                    }

                    # Search the slow way for sublime
                    Write-Verbose "Editor still not found, getting desperate:"
                    if(($Editor = Get-Item "C:\Program Files\DevTools\Sublime Text ?\sublime_text.exe" -ErrorAction SilentlyContinue | Sort {$_.VersionInfo.FileVersion} -Descending | Select-Object -First 1) -or
                       ($Editor = Get-ChildItem C:\Program*\* -recurse -filter "sublime_text.exe" -ErrorAction SilentlyContinue | Select-Object -First 1))
                    {
                        $Parameters = "-n -w"
                        break
                    }

                    if(($Editor = Get-ChildItem "C:\Program Files\Notepad++\notepad++.exe" -recurse -filter "notepad++.exe" -ErrorAction SilentlyContinue | Select-Object -First 1) -or
                       ($Editor = Get-ChildItem C:\Program*\* -recurse -filter "notepad++.exe" -ErrorAction SilentlyContinue | Select-Object -First 1))
                    {
                        $Parameters = "-multiInst"
                        break
                    }

                    # Settling for Notepad
                    Write-Verbose "Editor not found, settling for notepad"
                    $Editor = "notepad"

                    if(!$Editor -or !(Get-Command $Editor -ErrorAction SilentlyContinue -ErrorVariable NotFound)) { 
                        if($NotFound) { $PSCmdlet.ThrowTerminatingError( $NotFound[0] ) }
                        else { 
                            throw "Could not find an editor (not even notepad!)"
                        }
                    }
                } while($false)

                $PSEditor = New-Object PSObject -Property @{
                        Command = "$Editor"
                        Parameters = "$Parameters"
                } | Add-Member ScriptMethod ToString -Value { "'" + $this.Command + "' " + $this.Parameters } -Force -PassThru

                # There are several reasons we might need to update the editor variable
                if($PSBoundParameters.ContainsKey("Editor") -or 
                   $PSBoundParameters.ContainsKey("Parameters") -or 
                   !(Test-Path variable:global:PSeditor) -or 
                   ($PSEditor.Command -ne $Editor))
                {
                    # Store it pre-parsed and everything in the current session:
                    Write-Verbose "Setting global preference variable for Editor: PSEditor"
                    $global:PSEditor = $PSEditor

                    # Store it stickily in the environment variable
                    if(![Environment]::GetEnvironmentVariable("Editor", "User")) {
                        Write-Verbose "Setting user environment variable: Editor"
                        [Environment]::SetEnvironmentVariable("Editor", "$PSEditor", "User")
                    }
                }
                return $PSEditor
            }
        }
