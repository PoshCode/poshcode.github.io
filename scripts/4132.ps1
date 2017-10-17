function Start-Demo {
    param(
       $Text = $PSISE.CurrentFile.Editor.Text
    )
    $psISE.CurrentPowerShellTab.ConsolePane.Clear()

    $Tokens =  $Errors = $null
    $Script:Editor = $PSISE.CurrentFile.Editor
    $Script:Text = $Script:Editor.Text
    $AST = [System.Management.Automation.Language.Parser]::ParseInput( $Text, [ref]$Tokens, [ref]$Errors )
    if($Errors) { $Errors | Write-Error }
    # Assumes that demo scripts don't have begin/process blocks
    $Script:Statements = $AST.EndBlock.Statements.Extent
    $Script:Index = $Script:Offset = 0

    $Function:Prompt = { PreDemoPrompt; Pop-Demo }
}

function Stop-Demo {
    $Function:Prompt = $function:PreDemoPrompt
}

function Pop-Demo {
    if($Script:Index -lt $Script:Statements.Count) {
        $Statement = $Script:Statements[$Script:Index]
        # use the offset to make sure we type any leading comments, and not just the statement
        # $DemoStep = $Script:Text.Substring($Script:Offset, $Statement.EndOffset - $Script:Offset).TrimStart("`r`n")
        
        $DemoStep = $Statement.Text

        $Script:Editor.Select($Statement.StartLineNumber, $Statement.StartColumnNumber, $Statement.EndLineNumber, $Statement.EndColumnNumber)
        $Script:Offset = $Statement.EndOffset + 1
        # put it in the console
        $psISE.CurrentPowerShellTab.ConsolePane.InputText = $DemoStep
        $psISE.CurrentPowerShellTab.ConsolePane.Focus()
        $Script:Index += 1
    } else {
        Stop-Demo
    }
}

$function:PreDemoPrompt = $function:Prompt

if(!($psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.DisplayName -eq "Start Demo")) {
    try {
        $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Start Demo',{Start-Demo},"F6")
    } catch [System.Management.Automation.MethodInvocationException] {
        $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Start Demo',{Start-Demo},$null)
    }
}
