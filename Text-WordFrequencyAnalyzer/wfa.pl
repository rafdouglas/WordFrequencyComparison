use strict;
use warnings;

use FindBin qw($Bin $Script);

#use File::Slurp;
use Data::Printer;
use YAML::Tiny;
use File::Path;

use lib "$FindBin::Bin".'/lib/Text/';
use WordFrequencyAnalyzer;



my $_file_in	= shift; #'book.txt';
my $_corpus_in	= 'data/count_1w.txt';


my $_hr_filein->{'book1'}	= Text::WordFrequencyAnalyzer::slurp_text($_file_in);
#print scalar keys %$_hr_filein;

my $_hr_corpus	= Text::WordFrequencyAnalyzer::read_wordcount_file($_corpus_in);
warn $_hr_corpus->{'ngrams'}->{'the'};

Text::WordFrequencyAnalyzer::match_vs_corpus($_hr_corpus,$_hr_filein->{'book1'},$_file_in);