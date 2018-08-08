New-UIWidget { 
   Grid {
      $shadow = DropShadowEffect -ShadowDepth 0 -BlurRadius 5 -Direction 0
      Ellipse -Name Hour   -Fill Transparent -Stroke Black -StrokeThickness 100 -Width 350 -Height 350 -StrokeDashArray 7.85,7.85 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 }
      Ellipse -Name Minute -Fill Transparent -Stroke Gray -StrokeThickness 75 -Width 325 -Height 325 -StrokeDashArray 10.468,10.468 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 }
      Ellipse -Name Second -Fill Transparent -Stroke White -StrokeThickness 50 -Width 300 -Height 300 -StrokeDashArray 15.71,15.71 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 }
   }
} -Refresh "00:00:00.2" { 
   $now = Get-Date
   $Hour.StrokeDashArray[0]   = $Hour.StrokeDashArray[1]/60 * $now.Hour * 5
   $Minute.StrokeDashArray[0] = $Minute.StrokeDashArray[1]/60 * $now.Minute
   $Second.StrokeDashArray[0] = $Second.StrokeDashArray[1]/60 * $now.Second
}


