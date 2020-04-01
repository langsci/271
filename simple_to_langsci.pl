#! /usr/bin/perl -w
## Convert expex etc to LangSci Press (March-April 2020)
use 5.010;
use strict;
use utf8;
use open ':std', ':encoding(utf8)';

my $filename = shift or die "Need input filename";
my $outfile = "ogs-$filename";

open(my $fh, "<", $filename) or die "Cannot open file $filename";
#open (my $fh, "<:encoding(utf-8)", $filename);
open(my $outfh, ">", $outfile) or die "Cannot open file $outfile";

my $openExample = 0;

while (my $line = <$fh>) {
	# Expex
	if ($openExample) {
		if ($line =~ /(\s*?)\Q\xe\E/) {
			$line =~ s/(\s*?)\Q\xe\E/ $1\\z\n\\z /;
			$openExample = 0;
		}
		elsif ($line =~ /(\s*?)\Q\a\E/) {
			$line =~ s/(\s*?)\Q\a\E/ $1\\ex /;
		}
	}
	elsif ($line =~ /\Q\pex\E/) {
		#$line =~ s/\Q\pex\E/ \\ea\n\\ea /;
		$line =~ s/\Q\pex\E(.*?)(\\\\)?$/ \\begin\{exe\}\n \\ex $1 \n \\begin\{xlist\} /;
		$openExample = 1;
	}
	elsif ($line =~ /\Q\ex\E/) {
		#$line =~ s/(\s*?)\Q\ex\E/ $1\\ea /;
		$line =~ s/(\s*?)\Q\ex\E(.*?)(\\\\)?$/ $1\\begin\{exe\}\n\\ex $2 /;
	}
	
	$line =~ s/(\s*?)\Q\xe\E/ $1\\z /; 
	
	$line =~ s/(\s*?)\Q\gla\E/ $1\\gll /;
	$line =~ s/(\s*?)\Q\glb\E/ $1 /;
	$line =~ s/(\s*?)\Q\glft\E(.*)\/\// $1\\glt$2 /;
	#$line =~ sm= // = \\ =;
	$line =~ s/\/\//\\\\/;
	$line =~ s/\Q\begingl\E//;
	$line =~ s/\Q\endgl\E//;
	
	$line =~ s/^(.*?)\\rightcomment\{(.*?)\}(.*)$/$1$3 \\jambox\{$2\}/;

	# Tables
	# find a fix for hdashline
	$line =~ s/\\hdashline/\\hline \%\%/;

	print $outfh $line;
}

close($fh);
close($outfh);



