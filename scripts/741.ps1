function Start($app,$param) {
   if($param) {
      [Diagnostics.Process]::Start( $app, $param )
   } else {
      [Diagnostics.Process]::Start( $app )
   }
}
