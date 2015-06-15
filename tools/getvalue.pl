#!/usr/bin/perl -w
use strict;


sub usage
{
	exit(1);
}

while(scalar(@ARGV) > 0 && substr($ARGV[0], 0, 1) eq '-') {
    my $arg = shift;
	last if(substr($arg, 0, 1) ne "-");
	my $opt = substr($arg, 1, 1);

	if($opt eq "pwwwww") {
	}else{
		usage();
	}
}

if(scalar(@ARGV) < 0) { usage(); }
my $file = shift;

if(scalar(@ARGV) < 0) { usage(); }
my $var = shift;

open(FIC, "<$file") or dir("open $file");

while(<FIC>) {
	if(m/\b$var\s*=\s*(\S*)/) {
		print("$1\n");
		exit(0);
	}
}

exit(1);
