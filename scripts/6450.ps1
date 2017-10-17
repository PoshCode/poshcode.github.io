Add-Type -AssemblyName Office
Add-Type -AssemblyName Microsoft.Office.Interop.PowerPoint

function Out-Pptx {
   [CmdletBinding()]
   param(
      [Parameter(ValueFromPipeline=$true)]
      $Content,

      $Presentation = "~\SkyDrive\Presentations\Intro to PowerShell.pptx"
   )
   begin {
      try {
         $PowerPoint = [System.Runtime.InteropServices.Marshal]::GetActiveObject('PowerPoint.Application')
      } catch {
         $PowerPoint = New-Object -ComObject PowerPoint.Application
         $PowerPoint.visible = [Microsoft.Office.Core.MsoTriState]::MsoTrue
         $Presentation = $PowerPoint.Presentations.Open( $Presentation )
      }

      if(!$Presentation) {
         $Last = $PowerPoint.Presentations.Count
         $Presentation = $PowerPoint.Presentations.Item($Last)
      }
   }

   process {
      $Count = $Presentation.Slides.Count
      $Slide = $Presentation.Slides.AddSlide($Count+1, $Presentation.Slides.Item($Count).CustomLayout)
      # $Slide.Layout = [Microsoft.Office.Interop.PowerPoint.PpSlideLayout]::ppLayoutText

      $slide.Shapes.Title.TextFrame.TextRange.Text = "PS> " + $MyInvocation.Line
      $Slide.Shapes.Item(2).TextFrame.TextRange.Text = $Content
   }
}
