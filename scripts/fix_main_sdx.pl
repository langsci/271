#! /usr/bin/perl -w
## Fix main.sdx which has entries of the form \indexentry {\isi {term}}
## Usage: perl scripts/fix_main_sdx.pl main.sdx <name_of_file>
## Run this, then makeindex -o main.snd <name_of_file>
use 5.010;
use strict;
use utf8;
use open ':std', ':encoding(utf8)';
#use File::Slurp::Unicode;

my $filename = "main.sdx";
my $outfile = shift or die "Specify output file (can overwrite main.sdx)";
my @entire_document;

open(my $fh, "<", $filename) or die "Cannot open main.sdx";
while (my $line = <$fh>) {
	if ($line =~ /\\emph/) { # \indexentry {\emph {by itself}|hyperindexformat{\see {agentivity}}}{237}
	#\indexentry {Agree|hyperpage}{233}
		$line =~ s/^(.*?)\\emph \{(.*?)\}(.*)$/$1$2\@\\textit\{$2\}$3/;
	}
	else {
		$line =~ s/\\isi \{(.*?)\}/$1/;
	}
	push (@entire_document, $line);
	#print $outfh $line;
}
close($fh);

open(my $outfh, ">", $outfile) or die "Cannot open $outfile for writing";
print $outfh join ('', @entire_document);
close($outfh);