include Make.inc
include VERSION

PROJECT=	fsvalue
MAINEXE?=	$(PROJECT)
MANPAGE=	$(MAINEXE).1
DOCHTML=	$(MAINEXE).html $(PROJECT)-TODO.html $(PROJECT)-changelog.html
DOCPDF=		$(MAINEXE).pdf
#DOCFILES=	$(DOCHTML) logo-ims-mail.png
DOCFILES=	$(DOCHTML)
PDFFILES=	$(DOCPDF)


include ps-cmn.mak
#
#  génération MAN et DOC
#
# MANINCLUDE += linkscdrpopper.adoc
#
# Pour générer la manpage du main-exe
#
$(MAINEXE).1:	$(MAINEXE).adoc $(MANINCLUDE) usage.txt
$(MAINEXE).html:$(MAINEXE).adoc $(MANINCLUDE) usage.txt  $(PROJECT)-TODO.html $(PROJECT)-changelog.html
$(MAINEXE).pdf: $(MAINEXE).adoc $(MANINCLUDE) usage.txt
#############



CXXFLAGS+= $(CFLAGS) -Wall --std=c++11 -I /usr/include/crypto++
LFLAGS+= -lboost_filesystem -lboost_system -lcrypto++ -licuuc


OBJS= \
	Filestamp.o\
	Fstamplist.o \
	fsvalue.o \
				

all: VERSION.h sysconfig.h $(MAINEXE) $(MANPAGE) $(DOCHTML) $(MOFILES)


$(MAINEXE): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) $(LFLAGS)

install: all
	install -d			$(bindir)
	install $(MAINEXE) $(bindir)/
	tools/installman.sh		$(mandir)	$(MANPAGE)

uninstall:
	rm -f $(bindir)/$(MAINEXE)
	tools/installman.sh -r  $(mandir) $(MANPAGE)


clean-doc: clean
	rm -f $(MANPAGE) $(DOCHTML) $(DOCPDF) *~ sysconfig.h 

clean:
	rm -f $(MAINEXE) *.o *.core VERSION.h
