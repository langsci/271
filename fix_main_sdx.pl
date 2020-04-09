#! /usr/bin/perl -w
## Fix main.sdx which has entries of the form \indexentry {\isi {term}}
## Run this, then makeindex -o main.snd main.sdx.fix
use 5.010;
use strict;
use utf8;
use open ':std', ':encoding(utf8)';
use File::Slurp::Unicode;

my $filename = "main.sdx";
my $outfile = "$filename.fix";

### Read in a dictionary of subject index terms

open(my $fh, "<", $filename) or die "Cannot open main.sdx";
open(my $outfh, ">", $outfile) or die "Cannot open file $outfile";

while (my $line = <$fh>) {
	$line =~ s/\\isi \{(.*?)\}/$1/;
	print $outfh $line;
}
close($fh);
close($outfh);