#!/bin/bash
set -e;

doman=1
dohtml=
dodoc=
dopdf=
noclean=
doctype="manpage";
a2x=
adv6=

usage()
{
	echo >&2 "$0 [-m] file(.adoc) [asciidoc options]";
	echo >&2 "-a : article";
	echo >&2 "-A : use a2x";
	echo >&2 "-p : output PDF";
	echo >&2 "-h : HTML output";
	echo >&2 "-d : docbook output";
	echo >&2 "-k : keep tmp files";
	exit 1;
}

while [[ $# -ge 1 && "$1" == -* ]]; do
	if [ $1 = "-m" ]; then
		doman=1;
	elif [ $1 = "-p" ]; then
		dopdf=1; doman=;
	elif [ $1 = "-h" ]; then
		dohtml=1; doman=;
	elif [ $1 = "-d" ]; then
		dodoc=1;
	elif [ $1 = "-a" ]; then
		doctype="article";
	elif [ $1 = "-A" ]; then
		a2x=1;
	elif [ $1 = "-k" ]; then
		noclean=1;
	else
		echo >&2 "unknown option $1";
		echo >&2
		usage
	fi
	shift
done

if [ $# -lt 1 ]; then
	usage;
fi
file="$1";
shift;

remops="$*";

file=`echo "$file" | sed 's/\.adoc$//'`;

[[ `2>&1 asciidoc --version` == asciidoc\ 6.* ]] && adv6=1;

# tmpbase="/tmp/` basename $0 `.tmp";
tmpbase="~$file";

if [ "$adv6" ]; then
	iconv -f iso8859-15 -t utf8 <"$file.adoc" >$tmpbase.iconv
fi
# cp -p "$file.adoc" "$tmpbase.iconv"
# [[ `2>&1 asciidoc --version` == *7.* ]] && unsafe="--unsafe"


if [ "$doman" ]; then
	#
	#  MAN
	#

	if false; then
		#
		#  Linuxdoc backend
		#
		asciidoc --unsafe --attribute=encoding=ISO-8859-15 -d $doctype -b linuxdoc $remops "$file.adoc"  >$tmpbase.xml

	elif false; then
		#
		# docbook -> man
		#
		asciidoc --unsafe --attribute=encoding=ISO-8859-15 -d $doctype -b docbook $remops "$file.adoc"  >$tmpbase.xml
		xsltproc --nonet /etc/asciidoc/docbook-xsl/manpage.xsl $tmpbase.xml

	elif false; then
		if [ ! "$adv6" ]; then	# V7
			#--attribute=encoding=ISO-8859-15
			asciidoc --unsafe -d $doctype -b docbook --attribute=sgml -o $tmpbase.sgml $remops "$file.adoc"
		else		# V6
			asciidoc -d $doctype -b docbook-sgml -o $tmpbase.sgml $remops "$tmpbase.iconv"
		fi
		docbook2man $tmpbase.sgml

	else
		asciidoc -d manpage -b docbook $remops "$file.adoc"
		if xsltproc /etc/asciidoc/docbook-xsl/manpage.xsl "$file.xml"; then
			rm -f "$file.xml"
		fi
	fi

elif [ "$dohtml" ]; then
	#
	# HTML
	#

	if [ ! "$adv6" ]; then	# V7
		# --attribute=encoding=ISO-8859-15
		asciidoc --unsafe --attribute=sgml -d $doctype  -a icons $remops  "$file.adoc"
	else		# V6
		asciidoc -d $doctype -b xhtml  -a icons -o "$file.html" $remops "$tmpbase.iconv"
	fi

elif [ "$dodoc" ]; then
	#
	#  DOCBOOK
	#

	# --attribute=encoding=ISO-8859-15
	asciidoc --unsafe --attribute=sgml -d $doctype  -a icons -b docbook $remops "$file.adoc"

elif [ "$dopdf" ]; then

	#
	#  PDF
	#
	if [ ! "$a2x" ]; then
		# --attribute=encoding=ISO-8859-15
		asciidoc --unsafe -b docbook -d article -o $tmpbase.xml $remops  "$file.adoc"
		xsltproc --nonet --stringparam callout.graphics 1 --stringparam navig.graphics 1         --stringparam admon.textlabel 1 --stringparam admon.graphics 1         --stringparam admon.graphics.path "/usr/share/asciidoc/images/icons/"  --stringparam callout.graphics.path "/usr/share/asciidoc/images/icons/callouts/"  --stringparam navig.graphics.path "/usr/share/asciidoc/images/icons/"  /etc/asciidoc/docbook-xsl/fo.xsl $tmpbase.xml >$tmpbase.fo
		cwd=`pwd`;
		# cd /usr/share/asciidoc/
		fop $tmpbase.fo -pdf "$cwd/$file.pdf"
		# cd $cwd
	else
		# --attribute=encoding=ISO-8859-15
		a2x -f pdf --asciidoc-opts="--unsafe -d $doctype $remops" "$file.adoc"
	fi
else
	echo >&2 "No format required";
	exit 1;
fi
rm -f manpage.refs manpage.links

if [ ! "$noclean" ]; then
	rm -f $tmpbase.iconv $tmpbase.xml $tmpbase.fo $tmpbase.sgml
	rm -f $tmpbase.iconv $tmpbase.fo
fi

