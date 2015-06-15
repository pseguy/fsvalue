#!/usr/bin/perl -w
use strict;
use Carp;


sub getDebian
{
	if( -f "changelog-debian" ) {
		open(FIC, "changelog-debian") or croak("open changelog-debian");

	}else{
		open(FIC, "debian/changelog") or croak("open debian/changelog");
	}

	$_ = <FIC>;
	print(STDERR "unexpected EOF\n") if(!defined($_));
	chomp();
	# cdrpopper (3.3.1-1) unstable; urgency=low

	my $drel = 0;

	if(!m/(\S+)\s+\((\d+)\.(\d+)\.(\d+)(-(\d+))?\)\s+(\w+)/) {
		print(STDERR "bad changelog format: $_\n");
		return(-1);
	}

	$drel = $6 if(defined($6));

	print("$1  $2 $3 $4 $drel  $7\n");
	close(FIC);
	return(0);
}


sub getPkgname
{
	open(FIC, "debian/control") or die("open debian/control");

	while(<FIC>) {
		if(m/\s*Package\s*:\s*(\S+)/) {
			print("$1\n");
			last;
		}
	}
}


sub getPrjname
{
	open(FIC, "debian/control") or die("open debian/control");

	while(<FIC>) {
		if(m/\s*Source\s*:\s*(\S+)/) {
			print("$1\n");
			last;
		}
	}
}


sub usage
{
	print(STDERR "$0 [opt]\n");
	print(STDERR "-p : get first package name\n");
	print(STDERR "-s : get Project name\n");
	exit(1);
}



my $dopkg;
my $doprj;


while(scalar(@ARGV) > 0 && substr($ARGV[0], 0, 1) eq '-') {
    my $arg = shift;
	last if(substr($arg, 0, 1) ne "-");
	my $opt = substr($arg, 1, 1);

	if($opt eq "p") {
		$dopkg=1;
	}elsif($opt eq "s") {
		$doprj=1;
	}else{
		usage();
	}
}

if($dopkg) {
	getPkgname
}elsif($doprj) {
	getPrjname
}else{
	getDebian();
}
