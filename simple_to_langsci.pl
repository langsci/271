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
my $rightComm = "";

#my $TABULARSTART = '\t\\begin\{tabularx\}';
#my $TABLESTART = '\\begin\{table\}[h]'.$TABULARSTART;

while (my $line = <$fh>) {

	# EXAMPLES (Expex to lingsci-gb4e)

	if ($openExample) {
		if ($line =~ /(\s*?)\Q\xe\E/) {
			$line =~ s/(\s*?)\Q\xe\E/ $1\\z\n\\z /;
			$openExample = 0;
		}
		elsif ($line =~ /(\s*?)\Q\a\E/) {
			$line =~ s/(\s*?)\Q\a\E(.*?)(\\\\)?$/ $1\\ex $2 /;
			$line =~ s/(\s*?)\Q\a\E(.*?)(\\\\)?$/ $1\\ex \{ $2 /; #open bracket for judgement
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
#		$line =~ s/(\s*?)\Q\ex\E(.*?)(\\\\)?$/ $1\\begin\{exe\}\n\\ex \{ $2 /; #open bracket for judgement
	}
	
	$line =~ s/(\s*?)\Q\xe\E/ $1\\z /; 

	# change textbf to glemph in examples
	$line =~ s/(.*)\Q\gla\E(.*?)\\textbf\{(.*?)\}(.*)/$1\\gla$2\\glemph\{$3\}$4/;
	$line =~ s/(.*)\Q\ex\E(.*?)\\textbf\{(.*?)\}(.*)/$1\\ex$2\\glemph\{$3\}$4/;
	# glemphu for secondary emphasis
	$line =~ s/(.*)\Q\gla\E(.*?)\\underline\{(.*?)\}(.*)/$1\\gla$2\\glemphu\{$3\}$4/;
	$line =~ s/(.*)\Q\ex\E(.*?)\\underline\{(.*?)\}(.*)/$1\\ex$2\\glemphu\{$3\}$4/;
	
	# store rightcomment from \gla, put it in \glb jambox
	if ($line =~ /^(.*?)\\rightcomment\{(.*?)\}(.*)$/) {
		$rightComm = $2;
		$line = $1.$3."\n";
		}
	if ($rightComm && $line =~ /(\s*?)\Q\glb\E(.*?)\/\//) {
		$line = $1.$2."\\\\ \\jambox\{".$rightComm."\}\n";
		$rightComm = "";
	}
	#$line =~ s/^(.*?)\\rightcomment\{(.*?)\}(.*)$/$1$3 \\jambox\{$2\}/;
		
	# clean up
	$line =~ s/(\s*?)\Q\gla\E/ $1\\gll /;
	$line =~ s/(\s*?)\Q\glb\E/ $1 /;
	$line =~ s/(\s*?)\Q\glft\E(.*)\/\// $1\\glt$2 \} /; # close judgment bracket
	#$line =~ sm= // = \\ =;
	$line =~ s/\/\//\\\\/;
	$line =~ s/\Q\begingl\E//;
	$line =~ s/\Q\endgl\E//;
	
	# judgments
	if ($line =~ /\\ljudge/) {
		$line =~ s/\{(\s*)\\ljudge\s*?\{(.*?)\}/$1\[$2\]\{/;
	}
	
	# trailingcitation
	$line =~ s/(.*?)\\trailingcitation\{(.*?)\}(.*)/$1 \\hfill $2$3/;
	
	# langinfo?
	
	
	# END EXAMPLES: if two upper-level \ex's follow each other - e.g. (8) and (9), manually remove the space created between them by \z \begin{exe}
	
	
	# TABLES
	# tabular to tabularx
	if ($line =~ /(.*?)\Q\begin{tabular}\E/) {
		$line =~ s/(.*?)\Q\begin{tabular}\E(.*)/$1\\begin\{tabularx\}\{\\textwidth\}$2\n \\lsptoprule/;
		$line =~ s/\|//g; # no vertical lines
	}
	$line =~ s/(.*?)\Q\end{tabular}\E(.*)/\\lspbottomrule\n $1\\end\{tabularx\}$2/;
	
	$line =~ s/\Q\hline\E/\\midrule/;
	if ($line =~ /multicolumn/) {
		$line =~ s/\|//g;	
	}
	$line =~ s/\\hdashline/\\tablevspace/;

	# END TABLES: still need to manually change \begin{table} and move \caption and \label to the bottom (if necessary)

	print $outfh $line;
}

close($fh);
close($outfh);



