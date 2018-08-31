#/usr/bin/wish

#
## NOTE This program might get its Tcl (for the sake of parsing) 
## specific procedures wrapped in a single Tcl namespace
#
proc parse_text { widget lang } {
   upvar 1 $widget textwidget;
   set text [$widget get 1.1 end];
   set SyntaxRules [dict create]
   set SyntaxRules [parse text]
   return SyntaxRules
}

## in this method we will
## duplicate some logic with
## parse_dbl_quotes, but that is
## necessery. 
proc parse { t } {
    upvar $t text
    set Variables [dict create]
    # possible values are plain,
    # DblQuote and Variable
    set Now plain

    for {set i 0; set c 0; set l 0; set vnum 0} { i < [string length "$text"]} { incr i } {
     }
}


## this procedure expects a 
## a text [whose begining at
## least is] enclosed in double
## quotes. The opening double
## quote must be present
proc parse_dbl_quotes { t } {
    upvar $t text
    set Variables [dict create]
    # possible values are plain
    # and variable
    set Now plain

    # TODO scan for setting variables with "set " and apply tags for variable' encounters
    for {set i 0; set c 0; set l 0; set vnum 0} { i < [string length "$text"]} { incr i } {
        if { [string compare "$Now" Variable] != 0} {
        if { [string compare [string index $i "$text"] {\$}] == 0 } {
            dict set Variables $vnum [dict create start "$c.$l" tag Variable]
            set Now Variable
        }
       }
       else {
           ## *If the character we are at is a double quote we must terminate
           if { regexp {\"} [string index $i $text ] == 0} {
               set Now Plain
               set Var [dict get Variables $vnum]
               dict set Var end "$c.$l"
               
           }

           ## *If the character we are at is non-alphanumeric consider variable name to have been collected
           if{[regexp {\W} string index $i "$text"]} {
               set Now Plain
               set Var [dict get Variables $vnum]
               dict set Var end "$c.$l"
           }
       }
       incr c;

       ## encountering a new line
       ## character. Reflect that
       ## in the program
       if {regexp {\n} [string index $i "$text"] == 0} {
           incr l;
           set c 0;
       }
     }

     ## here we are altering the
     ## variable passed to us by the
     ## caller. The caller must
     ## take this into account.
     ## A conventional for loop there
     ## might not be appropriate
     ## as it's making a copy of
     ## the iterated dictionary.
     set text [string range "$text" $i end]
     return $Variables
}

proc apply_syntax_tk { textwidget lang } {
    # //
    # // NOTE when passing accross Tk widget to
    # // a procedures, don't upvar it, as Tk
    # // widget identifiers are not variables
    # // (rather procedures)
    # //
    $textwidget tag configure comment -foreground #ececec
    $textwidget tag configure variable -foreground red
    $textwidget tag configure word_proc -foreground red
}

wm title . "Text-widget"

pack [text .textwidget]
# //
# // NOTE when passing accross Tk widget to
# // a procedures, don't upvar it, as Tk
# // widget identifiers are not variables
# // (rather procedures)
# //
apply_syntax_tk .textwidget "Tcl";
pack [button .btn -text "Parse" -command { parse_text .textwidget "Tcl"}]

