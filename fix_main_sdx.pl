#! /usr/bin/perl -w
## Fix main.sdx which has entries of the form \indexentry {\isi {term}}
## Run this, then makeindex -o main.snd main.sdx.fix
use 5.010;
use strict;
use utf8;
use open ':std', ':encoding(utf8)';
#use File::Slurp::Unicode;

my $filename = "main.sdx";
my $outfile = shift or die "Output file (could be the same)?";
my @entire_document;

open(my $fh, "<", $filename) or die "Cannot open main.sdx";
while (my $line = <$fh>) {
	$line =~ s/\\isi \{(.*?)\}/$1/;
	push (@entire_document, $line);
	#print $outfh $line;
}
close($fh);

open(my $outfh, ">", $outfile) or die "Cannot open $outfile for writing";
print $outfh join ('', @entire_document);
close($outfh);