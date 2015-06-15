#!/bin/sh

#
#  goal: drop the following lines:
#


#
#<!-- Links to usefull Debian websites providing more information about
#        this package -->
#<ul class="navbar">
#        <li>
#                <a href="http://packages.debian.org/src:cdrpopper">Package Information</a>
#        </li>
#        <li>
#                <a href="http://packages.qa.debian.org/cdrpopper">Package Developer Information</a>
#        </li>
#        <li>
#                <a href="http://bugs.debian.org/src:cdrpopper">Bug Information</a>
#        </li>
#</ul>

if [ ! "$1" ]; then
	echo >&2 "Missing file name";
	exit 1;
fi

if [ ! "$2" ]; then
	echo >&2 "Missing project name";
	exit 1;
fi
PROJECT="$2";

ed -s "$1" <<-EOT
/<!--[[:space:]]*Links to usefull Debian/ka
/<ul[[:space:]]\+class="navbar"/ka
/<\/ul>/kb
'a,'bd
,s/debian-www@lists\.debian\.org/pseguy@imsnetworks.com/g
,s?href="http://packages\.debian\.org/src:$PROJECT"?href="$PROJECT-project.html"?g
w
q
EOT

true;

# diff -w -B *-changelog.html  xxx.tmp
