#!/usr/bin/perl -w
# My perso changelog parser - Pascal Séguy
use strict;
use warnings;
use Carp;

my $para = "";
my $state = "out";
my $subcnt = 0;
my $newpara;
my $level = 0;


sub flushpara
{
	if($para ne "") {
		my $line = 0;

		if(open(CHILD, "-|")) {
			while(<CHILD>) {
				chomp;
				if($level == 1) {
					if($line == 0) {
						print("\n");
						if($newpara) {
							print("\n  * ");
						}else{
							print("    ");
						}
					}else{
						print("    ");
					}
				}elsif($level == 2) {
					if($line == 0) {
						print("\n");
						if($newpara) {
							print("    - ");
						}else{
							print("      ");
						}
					}else{
						print("      ");
					}
				}
				print("$_\n");
				++$line;
			}
		}else{
			if(open(CHILD2, "|-")) {
				print(CHILD2 "$para\n");
				exit 0;
			}else{
				exec("fmt -w65");
			}
			croak("exec fmt");
		}
		$para = "";
		$newpara = undef;
	}
}


sub getDebian
{
	open(FIC, "changelog-debian") or croak("changelog-debian");

	while(<FIC>) {
		chomp();

		if(m/^\s*$/) {	# blank
			if($state eq "detail") {
				flushpara();
				if($level == 2) { $level = 1; }
				++$subcnt;
			}

		}elsif(m/(\S+)\s+\((\d+)\.(\d+)\.(\d+)(-(\d+))?\)\s+(\w+)/) { # ex: cdrpopper (3.3.1-1) unstable; urgency=low
			flushpara();

			print("$_\n");
			$state = "newrel";

		}elsif(m/^\s*\*\s+(\S+.*$)/){	# start un paragraphe qui commence avec un '*'

			flushpara();
			$newpara = 1;
			$state = "detail";
			$level = 1;
			$subcnt = 0;
			$para = "$1";

		}elsif(m/^\s*\-\s+(\S+.*$)/){	# start un paragraphe qui commence avec un '-'

			flushpara();
			$newpara = 1;
			$state = "detail";
			$level = 2;
			$subcnt = 0;
			$para = "$1";

		}elsif(m/^\s*\--\s+(\S+.*$)/){	# -- Pascal Séguy <ps@b3g-telecom.com>  Mon, 11 Feb 2008 11:51:47 +0100

			flushpara();
			$level = 0;
			$state = "out";
			print("\n -- $1\n\n\n");

		}elsif(m/^\s*(\S+.*$)/) { # line text

			if($state ne "detail") {
				print(STDERR "state $state: $1\n");
				exit(1);
			}
			if($para ne "") { $para .= " "; }
			$para .= $1;
		}
	}
	close(FIC);
	return(0);
}



sub usage
{
	print(STDERR "$0 [opt]\n");
	exit(1);
}



my $dopkg;


while(scalar(@ARGV) > 0 && substr($ARGV[0], 0, 1) eq '-') {
    my $arg = shift;
	last if(substr($arg, 0, 1) ne "-");
	my $opt = substr($arg, 1, 1);

	if($opt eq "p") {
		$dopkg=1;
	}else{
		usage();
	}
}

getDebian();

