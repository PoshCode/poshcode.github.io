#requires -version 2.0
function Get-UserStatus {
  $script:usr = [Security.Principal.WindowsIdentity]::GetCurrent()
  return (New-Object Security.Principal.WindowsPrincipal $usr).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
  )
}

function Get-ImageFromString($img) {
  [Drawing.Image]::FromStream((New-Object IO.MemoryStream(
    ($$ = [Convert]::FromBase64String($img)), 0, $$.Length))
  )
}

function Get-NameSpaces([String]$root) {
  (New-Object Management.ManagementClass(
      $root, [Management.ManagementPath]'__NAMESPACE', $null
    )
  ).PSBase.GetInstances() | % {
    return (New-Object Windows.Forms.TreeNode).Nodes.Add($_.Name)
  }
}

function Get-SubNameSpaces([Windows.Forms.TreeNode[]]$nodes) {
  foreach ($nod in $nodes) {
    Get-NameSpaces ('root\' + $nod.FullPath) | % {$nod.Nodes.Add($_)}
  }
}

function Get-FilteredClasses([String]$root, [String]$mask) {
  if ([String]::IsNullOrEmpty($tsWCard.Text)) {$mask = '*'}
  
  (New-Object Management.ManagementClass($root, $obj)
  ).PSBase.GetSubclasses($enm) | % {
    if ($_.Name -like $mask) {
      $itm = $lvList1.Items.Add($_.Name, 1)
      try {$itm.SubItems.Add($_.PSBase.Qualifiers.Item("Description").Value)}
      catch{$itm.SubItems.Add("<Not described>")}
    }
  }
  
  if ($lvList1.Items.Count -ne 0) {
    $lvList1.AutoResizeColumns([Windows.Forms.ColumnHeaderAutoResizeStyle]::ColumnContent)
    Out-ClassesNumber
  }
}

function Select-AllItems {
  $lvList1.Items.Clear()
  Reset-AllMessages
  
  if ($tvRoots.SelectedNode) {
    $script:cur = 'root\' + $tvRoots.SelectedNode.FullPath
    Get-FilteredClasses $cur ($tsWCard.Text + '*')
    $frmMain.Text = $cur + ' - WMI Explorer'
  }
}

function Reset-AllMessages {
  $lvList2, $lvList3, $lvList4 | % {$_.Items.Clear()}
  $rtbData.Clear()
  $sbLbl_2, $sbLbl_3, $sbLbl_4 | % {$_.Text = [String]::Empty}
}

function Out-ClassesNumber {
  $sbLbl_1.Text = "Classes: " + $lvList1.Items.Count.ToString()
}

function Select-FilledTab {
  if (-not [String]::IsNullOrEmpty($rtbData.Text)) {
    $tabCtrl.SelectedTab = $tpPage3
  }
  else {
    if ($lvList3.Items.Count -eq 0 -and $lvList4.Items.Count -ne 0) {
      $tabCtrl.SelectedTab = $tpPage2
    }
    else {
      $tabCtrl.SelectedTab = $tpPage1
    }
  }
}

function Get-WmiItems($e) {
  foreach ($prop in $e.PSBase.Properties) {
    $rtbData.SelectionFont = $bold
    $rtbData.AppendText($prop.Name + ": ")
    $rtbData.SelectionFont = $norm
    
    if ($prop.Value -eq $null) {
      $rtbData.AppendText("`n")
    }
    elseif ($prop.IsArray) {
      $ofs = ";"
      $rtbData.AppendText("$($prop.Value)")
      $ofs = $null
      $rtbData.AppendText("`n")
    }
    else {
      $rtbData.AppendText("$($prop.Value)`n")
    }
  }
  $rtbData.AppendText("`n$('=' * 100)`n")
  Select-FilledTab
}

function Reset-TopMessages {
  $lvList1.Items.Clear()
  $sbLbl_1.Text = "Query Mode"
  $frmMain.Text = "WMI Explorer"
  $tabCtrl.SelectedTab = $tpPage3
  
  Reset-AllMessages
}

$mnuPane_Click= {
  $toggle =! $mnuPane.Checked
  $mnuPane.Checked = $toggle
  $scSplt1.Panel2Collapsed =! $toggle
}

$mnuMore_Click= {
  $toggle =! $mnuMore.Checked
  $mnuMore.Checked = $toggle
  $tsStrip.Visible = $toggle
}

$mnuSBar_Click= {
  $toggle =! $mnuSBar.Checked
  $mnuSbar.Checked = $toggle
  $sbStrip.Visible = $toggle
}

$tsWCard_TextChanged= {
  if (Get-UserStatus) {
    Reset-AllMessages
    switch ([String]::IsNullOrEmpty($tsWCard.Text)) {
      $true {Select-AllItems}
      default {
        if ($lvList1.Items.Count -ne 0) {
          $lvList1.Items | % {if ($_.Text -notlike ($tsWCard.Text + '*')) {$_.Remove()}}
          Out-ClassesNumber
        }
      }
    }
    $sbLbl_2, $sbLbl_3 | % {$_.Text = [String]::Empty}
  }
}

$tsQuery_GotFocus= {
  Reset-TopMessages
  $tsWCard.Text = [String]::Empty
  $lvList1, $lvList2 | % {
    $_.AutoResizeColumns([Windows.Forms.ColumnHeaderAutoResizeStyle]::ColumnContent)
  }
}

$tsQTest_Click= {
  Reset-TopMessages

  try {
    if (-not [String]::IsNullOrEmpty($tsQuery.Text)) {
      ([wmisearcher]$tsQuery.Text).Get() | % {
        Get-WmiItems $_
      }
    }
  }
  catch {}
}

$tvRoots_AfterSelect= {
  $tabCtrl.SelectedTab = $tpPage1
  Select-AllItems
}

$lvList1_Click= {
  $ErrorActionPreference = 0
  Reset-AllMessages
  
  for ($i = 0; $i -lt $lvList1.Items.Count; $i++) {
    if ($lvList1.Items[$i].Selected) {
      $path = $cur + ":" + $lvList1.Items[$i].Text
      $wmi = (New-Object Management.ManagementClass($path, $obj)).PSBase
    }
  }
  
  $wmi.Methods | % {
    $itm = $lvList2.Items.Add($_.Name, 2)
    $itm.SubItems.Add($_.Origin)
    $itm.SubItems.Add([String]::Empty)
    $itm.SubItems.Add([String]::Empty)
    $itm.SubItems.Add([String]::Empty)
    try {
      $itm.SubItems.Add($_.PSBase.Qualifiers["Description"].Value)
    }
    catch {
      $itm.SubItems.Add([String]::Empty)
    }
  }

  $wmi.Properties | % {
    $itm = $lvList2.Items.Add($_.Name, 3)
    $itm.SubItems.Add([String]::Empty)
    $itm.SubItems.Add($_.Type.ToString())
    $itm.SubItems.Add($_.IsLocal.ToString())
    $itm.SubItems.Add($_.IsArray.ToString())
    try {
      $itm.SubItems.Add($_.PSBase.Qualifiers["Description"].Value)
    }
    catch {
      $itm.SubItems.Add([String]::Empty)
    }
  }

  $wmi.Derivation | % {$lvList3.Items.Add($_, 1)}

  $wmi.Qualifiers | % {
    $itm = $lvList4.Items.Add($_.Name, 4)
    $itm.SubItems.Add($_.Value.ToString())
    $itm.SubItems.Add($_.IsAmended.ToString())
    $itm.SubItems.Add($_.IsLocal.ToString())
    $itm.SubItems.Add($_.IsOverridable.ToString())
    $itm.SubItems.Add($_.PropagatesToInstance.ToString())
    $itm.SubItems.Add($_.PropagatesToSubclass.ToString())
  }

  $ins = $wmi.GetInstances()
  if ($ins.Count -ne 0) {
    $ins | % {
      Get-WmiItems $_
    }
  }
  else {Select-FilledTab}
  
  $lvList2.AutoResizeColumns([Windows.Forms.ColumnHeaderAutoResizeStyle]::ColumnContent)
  if ($lvList3.Items.Count -ne 0) {
    $lvList3.AutoResizeColumns([Windows.Forms.ColumnHeaderAutoResizeStyle]::ColumnContent)
  }
  $sbLbl_2.Text = "Methods: " + $wmi.Methods.Count.ToString()
  $sbLbl_3.Text = "Properties: " + $wmi.Properties.Count.ToString()
  $sbLbl_4.Text = "Instances: " + $(switch($ins.Count -eq $null){$true{'0'}default{$ins.Count.ToString()}})
  $frmMain.Text = $path + ' - WMI Explorer'
}

$frmMain_Load= {
  if (Get-UserStatus) {
    Get-NameSpaces 'root' | % {$tvRoots.Nodes.Add($_)}
    Get-SubNameSpaces $tvRoots.Nodes
    
    $obj = New-Object Management.ObjectGetOptions
    $enm = New-Object Management.EnumerationOptions
    #both "True"
    $obj.UseAmendedQualifiers = $true
    $enm.EnumerateDeep = $true
    
    $sbLbl_1.Text = "Ready"
  }
  else {
    $sbLbl_1.Font = $bold
    $sbLbl_1.ForeColor = "Crimson"
    $sbLbl_1.Text = $usr.Name + " is not admin."
  }
}

function frmMain_Show {
  [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [Windows.Forms.Application]::EnableVisualStyles()
  #
  #fonts
  #
  $bold = New-Object Drawing.Font("Microsoft Sans Serif", 9, [Drawing.FontStyle]::Bold)
  $norm = New-Object Drawing.Font("Microsoft Sans Serif", 9, [Drawing.FontStyle]::Regular)
  #
  #resources
  #
  $ico = [Drawing.Icon]::ExtractAssociatedIcon(($PSHome + '\powershell.exe'))
  #
  #namespace picture
  #
  $img1 = "Qk1mAgAAAAAAADYAAAAoAAAADQAAAA4AAAABABgAAAAAADACAAAAAAAAAAAAAAAAAAAAAAAA//////" + `
          "//////////////////////////////////////////////AP///////////wAAAAAAAAAAAP///wAA" + `
          "AAAAAAAAAP///////////wD///////8AAAAAAAD///////////////////8AAAAAAAD///////8A//" + `
          "//////AAAAAAAA////////////////////AAAAAAAA////////AP///////wAAAAAAAP//////////" + `
          "/////////wAAAAAAAP///////wD///////8AAAAAAAD///////////////////8AAAAAAAD///////" + `
          "8A////////AAAAAAAA////////////////////AAAAAAAA////////AAAAAAAAAAAAAP//////////" + `
          "/////////////////wAAAAAAAAAAAAD///////8AAAAAAAD///////////////////8AAAAAAAD///" + `
          "////8A////////AAAAAAAA////////////////////AAAAAAAA////////AP///////wAAAAAAAP//" + `
          "/////////////////wAAAAAAAP///////wD///////8AAAAAAAD///////////////////8AAAAAAA" + `
          "D///////8A////////////AAAAAAAAAAAA////AAAAAAAAAAAA////////////AP//////////////" + `
          "/////////////////////////////////////wA="
  #
  #class picture
  #
  $img2 = "Qk02BQAAAAAAADYEAAAoAAAAEAAAABAAAAABAAgAAAAAAAABAAAAAAAAAAAAAAABAAAAAQAA////AN" + `
          "ju9gDYm1sA+O7jAMS3rQAUquEA/ez9ANrv9gDTZdIA2+/3AJeAbwCZMwAADGKBAI0tjAAOeJ4A/fD9" + `
          "AP/NmQD97f0A+q36ANxw2wAXmMgAbNbzAPuY+gCF4fUAUMvxAFDL8gA0wO8A997iAOm0fAC1YzUA+v" + `
          "TtABy17QDZbNgAa9f0AB217gA1wPAAHbXtALM8sgCF4PUAhuH0APnw5wD68uoAT8vxABy27gBr1vQA" + `
          "yXNDAIbh9QAvvu8ANMDwAPnx6QD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADIyMjIyMjIyMjIAAwAyMjIyMjIyMjIyMjIAMQsDADIyMj" + `
          "IyMjIyMjIyHh0CCwMAMjIyMjIyMjIECgIQHAILAwAyMjIyMjIyBDIDAhAcAgsDMjIyADIyMgQyMgMC" + `
          "EC0oADIyAAcAMjIEMjIyGwIpADIyAAcOBwAyBDIyBg0bADIyAAcOKw4HAAQyBiUTDREAMgEOKhovDA" + `
          "oKCiASFhMNEQAFFyEYMCIMATIGCBIWEw0RAQUuFRkjHwwBMgYIEggGAAAJBSYVGRokDAEADwgPADIy" + `
          "AAkFJywYFAEAMgAPADIyMjIACQUXFAEAMjIyADIyMjIyMgAJBQEAMjIyMjIyMjI="
  #
  #method picture
  #
  $img3 = "Qk3mBAAAAAAAADYEAAAoAAAAEAAAAAsAAAABAAgAAAAAALAAAAAAAAAAAAAAAAABAAAAAQAA0GnPAK" + `
          "61rADw1fAAq/D3APuY+gDvpe4ArNXVALxvuwDy2/IAfi5+AKlQqACePJ4Aq+XpAPPg8gD7q/oAfS18" + `
          "APuZ+gDVb9UAl1KWAN6Y3QDUbtMA+5v6AOzS7ACtu7UAjjWNAK6kmADkyuQA4q/iAOyR6wCqUqkAci" + `
          "RxAO3Y7QDuvu4A+5/6AKzOzAD05vQAj0aOAJFOkADr0esArpmKANJt0QCWOJUA8OPwAO+d7gDz4/MA" + `
          "qE+nAPuu+gCr4uUAp1CmAOjR6AB7K3oA55jmAK6nnADmzOYA46zjAKzEwQDqkOkAgDB/AKpQqQB/MH" + `
          "4AfC58AHUndQDPiM8A////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD8/Pz8/Pz8/Pz8/Fh41Pz8/Pz8/Pz8/Pz8/Hwo5PSY/Pz" + `
          "8/Pz8/Pz8/MToACSkyAj8/Ay8iFzQ/GgooFDsLGA8/Pz8/Pz8/Px0AEQcTJAsJPwMMBjcBGT8tKAcF" + `
          "ISsSPD8/Pz8/Pz8/MAcFFQQQMyU/Pz8DBgEnPz4bDgQEOD4jPz8/Pz8/Pz8CPiAuHD4NPz8/Pz8/Pz" + `
          "8/Pwg+Nj4sPz8/Pz8/Pz8/Pz8/CD4qPz8/"
  #
  #property picture
  #
  $img4 = "Qk02BQAAAAAAADYEAAAoAAAAEAAAABAAAAABAAgAAAAAAAABAAAAAAAAAAAAAAABAAAAAQAAxK+iAP" + `
          "///wD7/f8AVE5GAN+dfQBu6/8Aj6SsAP//9gBo7f8AVE9NAPzw6ADRyMEA0sjBAEphcABST0sAS2Fw" + `
          "AP///gACIS4AUk9MAHLh+QAVJzMAQaxTAFdNWQD+/v0Aeo+ZAOfr7QB6zeIA//nsADKy3wAVk8QAKZ" + `
          "c/ANnPyABhwd4AMDpPAP/l1gDCyNAA+OLSAKOsuABZeFsA+/TvAHx1cwCnkokAMp5BADG76gBdXGAA" + `
          "adv2AFOElQBXa4AAwsrOAH/j+QDf5OUA/d7LAP328gDRx8AAUmBnANq6qgC/yM0A/8WkAEBmUQCTtp" + `
          "kAhcyFAP/w4QCa06QAEajsAGrd9wD/6tIAGIwyAP77+ACAl6MAXnWEAAsQGwBccYAAHGYpAP/p3ABp" + `
          "nIkALqnWAPvu5gD/7eMAW21/AFjS8wCBprUAU1BMAIPh9gCknZYA/+LQACK6+gCw6/oAEAcKAP36+A" + `
          "BBPVAAT1ZlAEvH7QBYmK4AcMF9APHKtwD/6tUAcuL6AP7+/ABfoqYA//78ABRijgBRTksA+uneALCt" + `
          "rAD/+/kAQVxyANPJwgBWz/IAVL3cANTZ3QBOS0sAgJagAFCQjABAw+0AZ9f0AOXJuQBRcosAlbjEAO" + `
          "PZ0wBzhZMA4unpAIbT5QAdmcgAVlFNAB/Q/wD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + `
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH19fX19fX19fX19fX19fX0obgkJCXtRDhIOZQN9fX19Hw" + `
          "ECAgcHBxs9X0EDfX19fQwBAABoAAAAAAAzA319fX0MAQICY1gnTGYkVAN9fX19agEAABAAAAAAACID" + `
          "fX19fTUBAgIBF0M0CgpJA319fX0LAQICAQFhZ2l2TQN9fX19CwF4RTIBMA1LRixTfX07SAReBnkPKQ" + `
          "0gFnwUVxFaJkIEOXMGUg8aNghZHHodZDoeBAQENwYxLgghLU9xKz9wKn19fX0ZLwhcBRNAa1tVYhV9" + `
          "fX19I1ZOBQUFYHJsdEo8fX19fSV1bVBEbxh3Rzg+XX19fX19fX19fX19fX19fX0="
  #
  #qualifier picture
  #
  $img5 = "Qk32AgAAAAAAADYAAAAoAAAADgAAABAAAAABABgAAAAAAMACAAAAAAAAAAAAAAAAAAAAAAAA4evr//" + `
          "//////////////////////////////////////////////////AACZqKyZqKyZqKyZqKyZqKyZqKyZ" + `
          "qKyZqKyZqKyZqKyZqKyZqKyZqKz///8AAJmorP///+Ts7eTs7eTs7eTs7eTs7eTs7eTs7OTs7OTs7O" + `
          "Ps7JmorP///wAAmais////5+7u5+7v5+7v5+7v////////////////5+7u5u7umais////AACZqKz/" + `
          "///n7u7n7u/n7u+ZqKyZqKyZqKyZqKzn7u7n7u7m7u6ZqKz///8AAJmorP///+rw7+rw7////5morP" + `
          "///////////////+rw7+rv75morP///wAAmais////6vDvmaismaismaismaismaismais6vDv6vDv" + `
          "6u/vmais////AACZqKz////s8fCZqKz////////////////////////s8fHs8fGZqKz///8AAJmorP" + `
          "///+zx8JmorJmorJmorJmorJmorJmorOzx8ezx8ezx8ZmorP///wAAmais////7/Lwmais////7/Lx" + `
          "////////////////7vLx7/Lwmais////AACZqKz////v8vCZqKz///+ZqKyZqKyZqKyZqKzu8vHu8v" + `
          "Hv8vCZqKz///8AAJmorP////Dz8ZmorP///5morP////////////////Dz8f///5morP///wAAmais" + `
          "////8PPxmaismaismaismaismaismais8PPxmaismaismais7/PxAACZqKz////09PL19PP19PP19P" + `
          "P09PP09PP09PP09POZqKyZqKz08/P08/MAAJmorP///////////////////////////////////5mo" + `
          "rPTz8/Tz8/Tz8wAAmaismaismaismaismaismaismaismaismaismais9PTy9PTz9PTz9PTzAAA="
  #
  #tools strip button
  #
  $img6 = "Qk32AgAAAAAAADYAAAAoAAAADgAAABAAAAABABgAAAAAAMACAAAAAAAAAAAAAAAAAAAAAAAA//////" + `
          "//////////////////////////////////////////////////AAD/////////////////////////" + `
          "//////////////////////////////8AAP///////////////////////wAAAAAAAP////////////" + `
          "///////////wAA////////////////////////AAAAAAAA////////////////////////AAD/////" + `
          "//////////////////////////////////////////////////8AAP///////////////////////w" + `
          "AAAAAAAP///////////////////////wAA////////////////////////aGhoAAAAsrKy////////" + `
          "////////////AAD////////////////////////Z2dkAAAAAAACnp6f///////////////8AAP////" + `
          "///////////////////////9nZ2U1NTQAAALKysv///////////wAA////////////////////////" + `
          "////////8PDwAAAAAAAA////////////AAD///////////9NTU0AAADHx8f////////Hx8cAAABNTU" + `
          "3///////////8AAP///////////9DQ0AAAAAAAAAAAAAAAAAAAAAAAANDQ0P///////////wAA////" + `
          "////////////2dnZfHx8AAAAAAAAfHx82dnZ////////////////AAD///////////////////////" + `
          "////////////////////////////////8AAP//////////////////////////////////////////" + `
          "/////////////wAA////////////////////////////////////////////////////////AAA="
  #
  #form objects
  #
  $frmMain = New-Object Windows.Forms.Form
  $mnuMain = New-Object Windows.Forms.MenuStrip
  $mnuFile = New-Object Windows.Forms.ToolStripMenuItem
  $mnuExit = New-Object Windows.Forms.ToolStripMenuItem
  $mnuView = New-Object Windows.Forms.ToolStripMenuItem
  $mnuTool = New-Object Windows.Forms.ToolStripMenuItem
  $mnuPane = New-Object Windows.Forms.ToolStripMenuItem
  $mnuMore = New-Object Windows.Forms.ToolStripMenuItem
  $mnuSBar = New-Object Windows.Forms.ToolStripMenuItem
  $mnuHelp = New-Object Windows.Forms.ToolStripMenuItem
  $mnuInfo = New-Object Windows.Forms.ToolStripMenuItem
  $tsStrip = New-Object Windows.Forms.ToolStrip
  $tsLbl_1 = New-Object Windows.Forms.ToolStripLabel
  $tsLbl_2 = New-Object Windows.Forms.ToolStripLabel
  $tsWCard = New-Object Windows.Forms.ToolStripTextBox
  $tsQuery = New-Object Windows.Forms.ToolStripTextBox
  $tsQTest = New-Object Windows.Forms.ToolStripButton
  $tsDelim = New-Object Windows.Forms.ToolStripSeparator
  $scSplt1 = New-Object Windows.Forms.SplitContainer
  $scSplt2 = New-Object Windows.Forms.SplitContainer
  $scSplt3 = New-Object Windows.Forms.SplitContainer
  $tvRoots = New-Object Windows.Forms.TreeView
  $tabCtrl = New-Object Windows.Forms.TabControl
  $tpPage1 = New-Object Windows.Forms.TabPage
  $tpPage2 = New-Object Windows.Forms.TabPage
  $tpPage3 = New-Object Windows.Forms.TabPage
  $lvList1 = New-Object Windows.Forms.ListView
  $lvList2 = New-Object Windows.Forms.ListView
  $lvList3 = New-Object Windows.Forms.ListView
  $lvList4 = New-Object Windows.Forms.ListView
  $chCol_1 = New-Object Windows.Forms.ColumnHeader
  $chCol_2 = New-Object Windows.Forms.ColumnHeader
  $chCol_3 = New-Object Windows.Forms.ColumnHeader
  $chCol_4 = New-Object Windows.Forms.ColumnHeader
  $chCol_5 = New-Object Windows.Forms.ColumnHeader
  $chCol_6 = New-Object Windows.Forms.ColumnHeader
  $chCol_7 = New-Object Windows.Forms.ColumnHeader
  $chCol_8 = New-Object Windows.Forms.ColumnHeader
  $chCol_9 = New-Object Windows.Forms.ColumnHeader
  $chCol10 = New-Object Windows.Forms.ColumnHeader
  $chCol11 = New-Object Windows.Forms.ColumnHeader
  $chCol12 = New-Object Windows.Forms.ColumnHeader
  $chCol13 = New-Object Windows.Forms.ColumnHeader
  $chCol14 = New-Object Windows.Forms.ColumnHeader
  $chCol15 = New-Object Windows.Forms.ColumnHeader
  $chCol16 = New-Object Windows.Forms.ColumnHeader
  $rtbData = New-Object Windows.Forms.RichTextBox
  $imgList = New-Object Windows.Forms.ImageList
  $sbStrip = New-Object Windows.Forms.StatusStrip
  $sbLbl_1 = New-Object Windows.Forms.ToolStripStatusLabel
  $sbLbl_2 = New-Object Windows.Forms.ToolStripStatusLabel
  $sbLbl_3 = New-Object Windows.Forms.ToolStripStatusLabel
  $sbLbl_4 = New-Object Windows.Forms.ToolStripStatusLabel
  #
  #common properties
  #
  $mnuMain.Items.AddRange(@($mnuFile, $mnuView, $mnuHelp))
  $tsLbl_1.Text = "Filter:"
  $tslbl_2.Text = "Query:"
  $tsQuery.Size = New-Object Drawing.Size(247, 23)
  $scSplt1, $scSplt2, $scSplt3, $tvRoots, $tabCtrl, $lvList1, $lvList2, $lvList3, $lvList4, $rtbData | % {
    $_.Dock = "Fill"
  }
  $scSplt1, $scSplt2, $scSplt3 | % {$_.SplitterWidth = 1}
  $scSplt1, $scSplt3 | % {$_.Orientation = "Horizontal"}
  $lvList1, $lvList2, $lvList3, $lvList4 | % {
    $_.FullRowSelect = $true
    $_.MultiSelect = $false
    $_.ShowItemToolTips = $true
    $_.SmallImageList = $imgList
    $_.Sorting = "Ascending"
    $_.View = "Details"
  }
  $lvList1.Columns.AddRange(@($chCol_1, $chCol_2))
  $lvList2.Columns.AddRange(@($chCol_3, $chCol_4, $chCol_5, $chCol_6, $chCol_7, $chCol_8))
  $lvList3.Columns.AddRange(@($chCol_9))
  $lvList4.Columns.AddRange(@($chCol10, $chCol11, $chCol12, $chCol13, $chCol14, $chCol15, $chCol16))
  $lvList1.Add_Click($lvList1_Click)
  $lvList2.AllowColumnReorder = $true
  $chCol_1, $chCol_9 | % {$_.Text = "Class"}
  $chCol_2, $chCol_8 | % {$_.Text = "Description"}
  $chCol_3, $chCol10 | % {$_.Text = "Name"}
  $chCol_6, $chCol13 | % {$_.Text = "IsLocal"}
  $chCol_1, $chCol_2, $chCol_9, $chCol11, $chCol15, $chCol16 | % {$_.Width = 130}
  $chCol_3, $chCol_5, $chCol_6, $chCol_7, $chCol12 | % {$_.Width = 70}
  $tabCtrl.Controls.AddRange(@($tpPage1, $tpPage2, $tpPage3))
  $tpPage1, $tpPage2, $tpPage3 | % {$_.UseVisualStyleBackColor = $true}
  $rtbData.ReadOnly = $true
  $img1, $img2, $img3, $img4, $img5 | % {$imgList.Images.Add((Get-ImageFromString $_))}
  $sbStrip.Items.AddRange(@($sbLbl_1, $sbLbl_2, $sbLbl_3, $sbLbl_4))
  #
  #mnuFile
  #
  $mnuFile.DropDownItems.AddRange(@($mnuExit))
  $mnuFile.Text = "&File"
  #
  #mnuExit
  #
  $mnuExit.ShortcutKeys = "Control", "X"
  $mnuExit.Text = "E&xit"
  $mnuExit.Add_Click({$frmMain.Close()})
  #
  #mnuView
  #
  $mnuView.DropDownItems.AddRange(@($mnuTool, $mnuSBar))
  $mnuView.Text = "&View"
  #
  #mnuTool
  #
  $mnuTool.DropDownItems.AddRange(@($mnuPane, $mnuMore))
  $mnuTool.Text = "&Tools"
  #
  #mnuPane
  #
  $mnuPane.Checked = $true
  $mnuPane.ShortcutKeys = "Control", "L"
  $mnuPane.Text = "&Lower Pane"
  $mnuPane.Add_Click($mnuPane_Click)
  #
  #mnuMore
  #
  $mnuMore.ShortcutKeys = "Control", "F"
  $mnuMore.Text = "&Filter And Query"
  $mnuMore.Add_Click($mnuMore_Click)
  #
  #mnuSBar
  #
  $mnuSBar.Checked = $true
  $mnuSBar.Text = "&Status Bar"
  $mnuSBar.Add_Click($mnuSBar_Click)
  #
  #mnuHelp
  #
  $mnuHelp.DropDownItems.AddRange(@($mnuInfo))
  $mnuHelp.Text = "&Help"
  #
  #mnuInfo
  #
  $mnuInfo.Text = "About..."
  $mnuInfo.Add_Click({frmInfo_Show})
  #
  #tsStrip
  #
  $tsStrip.Items.AddRange(@($tsLbl_1, $tsWCard, $tsDelim, $tsLbl_2, $tsQuery, $tsQTest))
  $tsStrip.Visible = $false
  #
  #tsWCard
  #
  $tsWCard.Size = New-Object Drawing.Size(37, 19)
  $tsWCard.Add_TextChanged($tsWCard_TextChanged)
  #
  #tsQuery
  #
  $tsQuery.Text = "Select * From Win32_"
  $tsQuery.Add_GotFocus($tsQuery_GotFocus)
  #
  #tsQTest
  #
  $tsQTest.Image = (Get-ImageFromString $img6)
  $tsQTest.ToolTipText = "Test Query"
  $tsQTest.Add_Click($tsQTest_Click)
  #
  #scSplt1
  #
  $scSplt1.Panel1.Controls.Add($scSplt2)
  $scSplt1.Panel2.Controls.Add($tabCtrl)
  $scSplt1.Panel2MinSize = 23
  $scSplt1.SplitterDistance = 330
  #
  #scSplt2
  #
  $scSplt2.Panel1.Controls.Add($tvRoots)
  $scSplt2.Panel2.Controls.Add($scSplt3)
  $scSplt2.Panel1MinSize = 17
  $scSplt2.SplitterDistance = 30
  #
  #scSplt3
  #
  $scSplt3.Panel1.Controls.Add($lvList1)
  $scSplt3.Panel2.Controls.Add($lvList2)
  #
  #tvRoots
  #
  $tvRoots.ImageList = $imgList
  $tvRoots.Select()
  $tvRoots.Sorted = $true
  $tvRoots.Add_AfterExpand({Get-SubNameSpaces $_.Node.Nodes})
  $tvRoots.Add_AfterSelect($tvRoots_AfterSelect)
  #
  #tpPage1
  #
  $tpPage1.Controls.AddRange(@($lvList3))
  $tpPage1.Text = "Derivation"
  #
  #tpPage2
  #
  $tpPage2.Controls.AddRange(@($lvList4))
  $tpPage2.Text = "Qualifiers"
  #
  #tpPage3
  #
  $tpPage3.Controls.AddRange(@($rtbData))
  $tpPage3.Text = "Blank"
  #
  #chColX.Text
  #
  $chCol_4.Text = "Origin"
  $chCol_5.Text = "Type"
  $chCol_7.Text = "IsArray"
  $chCol11.Text = "Value"
  $chCol12.Text = "IsAmended"
  $chCol14.Text = "IsOverridable"
  $chCol15.Text = "PropagatesToInstance"
  $chCol16.Text = "PropagatesToSubclass"
  #
  #chCol_X.Width
  #
  $chCol_4.Width = 90
  $chCol_8.Width = 230
  $chCol10.Width = 170
  $chCol13.Width = 50
  $chCol14.Width = 80
  #
  #sbLbl_X
  #
  $sbLbl_2.ForeColor = "DarkMagenta"
  $sbLbl_3.ForeColor = "DarkGreen"
  $sbLbl_4.ForeColor = "DarkBlue"
  #
  #frmMain
  #
  $frmMain.ClientSize = New-Object Drawing.Size(800, 600)
  $frmMain.Controls.AddRange(@($scSplt1, $sbStrip, $tsStrip, $mnuMain))
  $frmMain.Icon = $ico
  $frmMain.MainMenuStrip = $mnuMain
  $frmMain.StartPosition = "CenterScreen"
  $frmMain.Text = "WMI Explorer"
  $frmMain.Add_Load($frmMain_Load)
  
  [void]$frmMain.ShowDialog()
}

function frmInfo_Show {
  $frmInfo = New-Object Windows.Forms.Form
  $pbImage = New-Object Windows.Forms.PictureBox
  $lblName = New-Object Windows.Forms.Label
  $lblCopy = New-Object Windows.Forms.Label
  $btnExit = New-Object Windows.Forms.Button
  #
  #pbImage
  #
  $pbImage.Image = $ico.ToBitmap()
  $pbImage.Location = New-Object Drawing.Point(16, 16)
  $pbImage.Size = New-Object Drawing.Size(32, 32)
  $pbImage.SizeMode = "StretchImage"
  #
  #lblName
  #
  $lblName.Font = $bold
  $lblName.Location = New-Object Drawing.Point(53, 19)
  $lblName.Size = New-Object Drawing.Size(360, 18)
  $lblName.Text = "WMI Explorer v2.05"
  #
  #lblCopy
  #
  $lblCopy.Location = New-Object Drawing.Point(67, 37)
  $lblCopy.Size = New-Object Drawing.Size(360, 23)
  $lblCopy.Text = "(C) 2013 greg zakharov forum.script-coding.com"
  #
  #btnExit
  #
  $btnExit.Location = New-Object Drawing.Point(135, 67)
  $btnExit.Text = "OK"
  #
  #frmInfo
  #
  $frmInfo.AcceptButton = $btnExit
  $frmInfo.CancelButton = $btnExit
  $frmInfo.ClientSize = New-Object Drawing.Size(350, 110)
  $frmInfo.ControlBox = $false
  $frmInfo.Controls.AddRange(@($pbImage, $lblName, $lblCopy, $btnExit))
  $frmInfo.FormBorderStyle = "FixedSingle"
  $frmInfo.ShowInTaskBar = $false
  $frmInfo.StartPosition = "CenterParent"
  $frmInfo.Text = "About..."
  $frmInfo.Add_Load($frmInfo_Load)

  [void]$frmInfo.ShowDialog()
}

frmMain_Show
