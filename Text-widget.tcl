#!/usr/bin/wish

source lib/TclParser.tcl

wm title . "Text-widget"

pack [text .textwidget]
# //
# // NOTE when passing accross Tk widget to
# // a procedures, don't upvar it, as Tk
# // widget identifiers are not variables
# // (rather procedures)
# //
Tcl::apply_syntax_tk .textwidget "Tcl";
pack [button .btn -text "Parse" -command { Tcl::parse_text .textwidget "Tcl"}]

