#!/usr/bin/make
CFLAGS	=
OS		?= $(shell uname -s)
# HOST	?= $(shell uname -n)
# USER=		$(shell logname)   # ne marche pas sous konsole
# USER	?= $(LOGNAME)
#PROJECT	?= $(shell tools/getdpkgversion.pl -p)
PROJECT	?= $(shell basename "$PWD")

#
# system dirs
#

include Make.inc
# BINDIR=			$(bindir)
# SBINDIR=		$(sbindir)
# ETCDIR=			$(etcdir)
# VARDIR=			$(vardir)
# MANDIR=			$(mandir)
# DOCDIR=			$(docdir)
prj_sharedir=	$(sharedir)/$(PROJECT)
prj_docdir=		$(docdir)/$(PROJECT)
prj_srvdir=		$(srvdir)/$(PROJECT)
# PERLLIBDIR=		$(perllibdir)


#
#  Divers
#


CXX ?=		g++
CXXFLAGS+= 	$(CFLAGS) -Wall -Wno-non-virtual-dtor -pthread
CC ?=		gcc


MANINCLUDE += mantailcmn.adoc VERSION

DOCFILES?=	$(DOCHTML)

%.1: %.adoc	$(MANINCLUDE)
	tools/asciidoc2man.sh -m $<  -a PROJECT=$(PROJECT)

%.5: %.adoc	$(MANINCLUDE)
	tools/asciidoc2man.sh -m $<  -a PROJECT=$(PROJECT)

%.7: %.adoc	$(MANINCLUDE)
	tools/asciidoc2man.sh -m $<  -a PROJECT=$(PROJECT)

%.8: %.adoc	$(MANINCLUDE)
	tools/asciidoc2man.sh -m $<  -a PROJECT=$(PROJECT)

%.html: %.adoc	$(MANINCLUDE)
	tools/asciidoc2man.sh -h $<  -a PROJECT=$(PROJECT)

%.pdf: %.adoc	$(MANINCLUDE)
	tools/asciidoc2man.sh -p $<  -a PROJECT=$(PROJECT)

default: all

$(PROJECT)-changelog.html: changelog-debian Makefile ps-cmn.mak tools/mkchangelog.pl tools/postparsecl.sh
	tools/mkchangelog.pl >"~$@"
	parsechangelog --all --format html "~$@" >"~~$@"
	tools/postparsecl.sh "~~$@" $(PROJECT)
	mv "~~$@" $@ && rm -f "~$@"

$(PROJECT)-TODO.html: TODO Makefile ps-cmn.mak
	echo "<html><head><META http-equiv='Content-Type' content='text/html' charset='UTF-8'></head><body><pre>" >"~$@"
	cat TODO >>"~$@"
	fmt "~$@" > "~~$@" && mv "~~$@" "~$@"
	echo "</body></html>" >>"~$@"
	mv "~$@" $@

usage.txt:
	test -f $(MAINEXE).pl || make $(MAINEXE)
	if test -x $(MAINEXE); then \
		sh -c "2>&1 ./$(MAINEXE) -?" >$@; \
	else \
		sh -c "2>&1 ./$(MAINEXE).pl -?" >$@; \
	fi || true

VERSION.h: VERSION ps-cmn.mak
	sed -r 's/(\S+)=(\S+)/#define \1 \2/' <VERSION >$@~ && mv $@~ $@

sysconfig.h: Make.inc
	echo "#define sysconfig_PROJECT \"$(PROJECT)\"" >$@~
	echo "#define sysconfig_prj_sharedir \"$(prj_sharedir)\"" >>$@~
	echo "#define sysconfig_etcdir \"$(etcdir)\"" >>$@~
	echo "#define sysconfig_sharedir \"$(sharedir)\"" >>$@~
	echo "#define sysconfig_vardir \"$(vardir)\"" >>$@~
	mv $@~ $@

#
# Denpendencies
#

# Add .d to Make's recognized suffixes.
SUFFIXES += .depend

#Find all the C++ files in the . directory
SOURCES:=$(shell find . -maxdepth 1 -name "*.cpp")
#These are the dependency files, which make will clean up after it creates them
DEPFILES:=$(patsubst %.cpp,%.depend,$(SOURCES))

#Chances are, these files don't exist.  GMake will create them and
#clean up automatically afterwards
-include $(DEPFILES)

#This is the rule for creating the dependency files
%.depend: %.cpp sysconfig.h
	$(CXX) $(CXXFLAGS) -MM -MT '$(patsubst %.cpp,%.o,$<)' $< -MF $@

#This rule does the compilation
%.o: %.cpp %.depend %.h
	$(CXX) $(CXXFLAGS) -o $@ -c $<
