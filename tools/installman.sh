#!/bin/bash
set -e;

rm=
mandir=

usage()
{
	echo >&2 "$0 [-r]  mandir  manpages...";
	echo >&2 "-r : remove";
	exit 1;
}

# while [[ $# -ge 1 && "$1" =~ "^-.+" ]]; do

while [[ $# -ge 1 && "$1" == -* ]]; do
	if [ $1 = "-r" ]; then
		rm=1;
	else
		echo >&2 "unknown option $1";
		echo >&2
		usage
	fi
	shift
done

if [ $# -lt 1 ]; then
	usage;
else
	mandir="$1";
	shift;
fi

set +x

while [ $# -ge 1 ]; do
	file="$1";
	ext=`echo "$file" | perl -we '$_ = <STDIN>; m/\.([^.]*?)$/  && print("$1\n");'`;

	if [ ! -z $rm ]; then
		rm -f "$mandir/man$ext/$file"
	else
		install -d -m 755 "$mandir/man$ext/"
		install -m 644 "$file" "$mandir/man$ext/"
	fi

	shift;
done
