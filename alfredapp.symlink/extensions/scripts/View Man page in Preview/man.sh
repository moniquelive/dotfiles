#!/bin/sh
#Based on this Mac OS X Hint:
#http://hints.macworld.com/article.php?story=20110511111211385
#Modified for input of multiple commands to seperate .PS files

COMMANDS="$@"
for f in $COMMANDS
do
    ps=`mktemp -t $f`.ps
	man -t $f > "$ps"
	open "$ps"
done