#! /usr/bin/perl -w
## Generate initial subject index based on text file
use 5.010;
use strict;
use utf8;
use open ':std', ':encoding(utf8)';
use File::Slurp::Unicode;

my $filename = shift or die "Need input filename";
my $outfile = "si-$filename";
my $subjfile = shift or die "Need input list";

### Read in a dictionary of subject index terms

open(my $subjfh, "<", $subjfile) or die "Cannot open list file";
my %subjects;

while (my $line = <$subjfh>) {
	chomp $line;
	my @terms = split(',', $line);
	my $indexTerm = $terms[0];
	$subjects{$indexTerm} = $indexTerm;
	foreach my $t (@terms) {
		$subjects{$t} = $indexTerm;
	}
}
close($subjfh);

### Insert indexation commands

my @entire_document = read_file($filename, encoding => 'utf8') or die "Cannot open file $filename";
my @new_document = "";
my $counter = 0;

# probably not a very efficient method
for my $ln (@entire_document) {
	$counter++;
	if ($ln =~ /^(\s*)\W/) {
		push (@new_document, $ln);
	}
	else {
		while ((my $key, my $value) = each (%subjects)) {
			my $indTerm = $value;
			my $textTerm = $key;
			if ($textTerm eq $indTerm) {
				$ln =~ s/$textTerm/\\isi\{$indTerm\}/g;
			}
			else {
				$ln =~ s/$textTerm/$textTerm\\is\{$indTerm\}/g;
			}
		}
		push (@new_document, $ln);
	}
	#open(my $fh, "<", $filename) or die "Cannot open file $filename";
	#open(my $outfh, ">", $outfile) or die "Cannot open file $outfile";
		#print $outfh $line;
	#}
	#close($fh);
	#close($outfh);
	# make new temp outfile
}

open(my $outfh, ">", $outfile) or die "Cannot open file $outfile";
print $outfh @new_document;
close($outfh);
print "Processed $counter lines.";