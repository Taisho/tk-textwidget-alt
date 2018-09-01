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
#
## This method already recieves a copy of the
## text being parsed, so we can throw away
## parts of it at will
proc parse { t } {
    upvar $t text
    set Tags [dict create]
    # possible values are plain,
    # DblQuote and Variable
    set Now plain

    for {set i 0; set c 0; set l 0; set tnum 0} { i < [string length "$text"]} { incr i } {
        if {[string compare [string index i "text"] "\n"] == 0} {
            incr l
            set c 0
        }

        if {[string compare $Now "plain"] == 0} {
            ##
            ## Opening double quote encountered
            ##
            if { [string compare [string index i "$text"] {\"}] == 0 } {
               set text [string range "$text" $i end]
               set tags [parse_dbl_quotes text]

               ## The last tag's end property is of our
               ## interest as we will use it to adjust
               ## $charIndex ($c) for current line
               set c 0
               ##TODO add charIndex from 'end' property from the
               ## last tag returned by parse_dbl_quotes to $c
               

               ##TODO $l (line index) will need to be adjusted
               ## based on what's "eaten" by the parse_dbl_quotes
               ## procedure

               ## we need to reset the $i index, as the $text
               ## variable would have lost a portion of it
               ## from its beginning 
               set i 0 

               ## We need to alter the tags returned by
               ## parse_dbl_quotes, as their opening
               ## and closing "addresses" (indexes in Tk
               ## terminology) is local to the substring
               ## being parsed. *This* procedures keeps
               ## track of indexes from the beginning of
               ## the text that was parsed.

               adjust_tags_indexes tags $c [expr $l-1]

               concat_dicts Tags tags
            }
        }
        incr c
     }

     return Tags
}

proc concat_dicts { D1 D2 } {
    upvar 1 D1 dict1;
    upvar 1 D2 dict2;
    set keys [dict keys dict1]
    set index [expr [llength keys] - 1]
    set d2Length [llength [dict keys dict2]]

    for {set i index; set y 0} {e < d2Length} {incr i; incr y} {
        dict set dict1 $i [dict get dict2 y]
    }
}

proc adjust_tags_indexes { T charOffset lineOffset} {
    upvar 1 T Tags
    ##
    ## We are going to alter only the $charIndex only
    ## for the first line
    ##
    set firstLine [dict get Tags 0]
    regexp {^([^.]+).([^.]+)} "[dict get firstLine start]" -> charIndex lineIndex
    set charIndex [expr $charIndex + $charOffset]
    dict set firstLine start "$charIndex.$lineIndex"

    #dict set Tags 
    foreach tag Tags {
        ## we are going to adjust only line numbers
        ## for all lines except the first one.
        regexp {^([^.]+).([^.]+)} "[dict get tag start]" -> charIndex lineIndex
        set lineIndex [expr $lineIndex + $lineOffset]
        dict set tag start "$charIndex.$lineIndex"
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

