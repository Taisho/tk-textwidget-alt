#/bin/wish

proc parse_text { widget lg } {
   upvar 1 $widget textwidget;
   upvar 1 $lg lang;
   set text [$widget get 1.1 end];
   set SyntaxRules [dict create]
   set SyntaxRules [parse "$text"]
   return SyntaxRules
}

proc parse { t } {
   upvar 1 $t text;
   set SyntaxRules [dict create]
   for {set i 0; set y 0; set n 0} {$i < [string length $t]} {incr i} {
      dict set SyntaxRules y
   }

   return SyntaxRules;
}

proc apply_syntax_tk { wdgt lang } {
    upvar 1 $wdgt textwidget;
    $wdgt tag configure comment -foreground #ececec
    $wdgt tag configure variable -foreground red
    $wdgt tag configure word_proc -foreground red
}

wm title . "Text-widget"

pack [text .textwidget]
apply_syntax_tk .textwidget "Tcl";
pack [button .btn -text "Parse" -command { parse_text .textwidget "Tcl"}]

