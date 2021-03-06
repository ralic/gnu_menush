#!/usr/bin/gawk -f

#    Copyright (C) 2008  Matthew King
#
#    This file is part of Menu Shell
#
#    Menu Shell is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful, but
#    WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This script is not very robust.
# There is NO error checking
# There are also no comments yet

/^\. / { print $0";"; next }

/^[[:alnum:]]/ {
    if (NF > 2)
	for (i = 3; i <= NF; i++)
	    $2 = $2" "$i;
    current_menu = $1;
    menu[current_menu] = "defined";
    current_entry = 0;
    title[current_menu] = $2;
    current_text = "head";

    next;
}

/^\"/ {
    if (match ($0, /^\"!/))
	text_line = gensub (/^\"![[:space:]]*(.*)/, "\\1 \"$options\";", "g");
    else
	text_line = "echo '" gensub (/^\"[[:space:]]*/, "", "g") "';";

    if (current_text == "head")
	text[current_menu] = text[current_menu]"\n"text_line;
    else
	text[current_menu] = text[current_menu]"\n"text_line;

    next;
}

/^[-\+]/ {
    if (substr ($0, 1, 1) == "-")
	option="invisible"
    else
	option="visible"
    $0 = gensub (/^[-\+][[:space:]]*/, "", "g");

    matchfunc=""
    if (match ($3, /^\?.*/)) {
	if (RLENGTH > 1)
	    matchfunc=$3
	else
	    matchfunc=$4
    }

    if (NF > 3)
	for (i = 4; i <= NF; i++)
	    $3 = $3" "$i;

    sub (/^\? */, "", matchfunc)
    sub (/^\? *[^ ]+ */, "", $3)

    echo="echo " # Space needed for tabbage
    if (match ($3, /^(<+|[>\|]) ?/)) {
	if (match ($3, /^>/))
	    echo="right "
	else if (match ($3, /^\|/))
	    echo="centre "
	else if (align = match ($3, /^<+/))
	    for (i = 0; i < align; i++)
		echo = echo"'\\t'"
	
	sub (/^(<+|[>\|]) ?/, "", $3)
    }

    current_text = "foot";

    current_entry++;
    entries[current_menu, current_entry] = "defined";
    entries_keys[current_menu, current_entry] = $1;
    entries_methods[current_menu, current_entry] = $2;
    size[current_menu] = current_entry;

    if (option == "visible") {
	# space is already added after echo
	if (matchfunc)
	    text[current_menu] = text[current_menu]"\n"matchfunc" && "
	else
	    text[current_menu] = text[current_menu]"\n"
	text[current_menu] = text[current_menu]echo"'"$3"';"
    }

    next;
}
    

/./ { print "# NOT PROCESSED", $0 }

END {
    for (this_menu in menu) {
	print "menu_"this_menu"_exists() {";
	print "true;";
	print "};";

	print "menu_"this_menu"_title() {";
	print "nothing;";
	print "WIDTH=$(echo -n '"title[this_menu]"'|wc -m);";
	print "centre '"title[this_menu]"';";
	print "};";

	print "menu_"this_menu"_text() {";
	print "nothing;";
	print text[this_menu];
	print "};";

	print "menu_"this_menu"_choose() {";
	print "nothing;";
	for (option in entries) {
	    if (index (option, this_menu) == 1) {
		print "if echo $1 | grep -q '["entries_keys[option]"]'; then";
		print "echo '"entries_methods[option]"';";
		print "fi;";
	    }
	}
	print "};";
    }
}
