package Text::WordFrequencyAnalyzer;

use 5.022001;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

use File::Slurp;
use Data::Printer;

my $_remove_capitalized_words	= 1;
my $_normalizer_base			= 1;
my $_output_integer				= 0;


our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Text::WordFrequencyAnalyzer ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.




sub word_counter {
	
	my ($_ar_input) = @_;

	my $_hr_count;
	my $_wordcount	= 0;
	
	foreach my $_word (@$_ar_input) {
		$_hr_count->{'ngrams'}->{lc $_word}++;
		$_wordcount++
	}
	
	$_hr_count->{'stats'}->{'wordcount'}	= $_wordcount;
	return $_hr_count;
}

sub write_ordered_output {
	
	my ($_fname,$_hr_count)	= @_;
	
 	write_file($_fname.'_out', '' );
	
 	foreach my $_word (sort { $_hr_count->{$b} <=> $_hr_count->{$a} } keys (%$_hr_count)) {	
	 	my $_str	= $_word.' '.$_hr_count->{$_word}."\n";
	 	write_file($_fname.'_out', {append=>1}, $_str);
 	}
 }

sub verify_and_read_file {
	
	my ($_fname)	= @_;
	
	if (not defined $_fname){
		warn 'ERR missing file name';
		return;
	}
	
	if (not -e $_fname) {
		warn 'ERR 404 on '.$_fname;
		return;
	}
	
	my $_r_filein	= read_file($_fname);
	
	return $_r_filein;
	
}

sub normalizer {
	
	my ($_hr_count) = @_;
	
	my $_wordcount	= $_hr_count->{'stats'}->{'wordcount'};
	
	my $_normalizer	=  $_normalizer_base / $_wordcount;
	print 'normalizer '.$_normalizer."\n";
	
	
	if ($_output_integer) {
		foreach my $_word (keys %{$_hr_count->{'ngrams'}}) {
			$_hr_count->{'normalized'}->{$_word}	= int( $_hr_count->{'ngrams'}->{$_word} * $_normalizer);
		}
	} else {
		foreach my $_word (keys %{$_hr_count->{'ngrams'}}) {
			$_hr_count->{'normalized'}->{$_word}	= $_hr_count->{'ngrams'}->{$_word} * $_normalizer;
		}
	}

	print 'the ngrams:     ' . $_hr_count->{'ngrams'}->{'the'}     . "\n";
	print 'the normalized: ' . $_hr_count->{'normalized'}->{'the'} . "\n";
	
	print 'plodded ngrams:     ' . $_hr_count->{'ngrams'}->{'plodded'}     . "\n";
	print 'plodded normalized: ' . $_hr_count->{'normalized'}->{'plodded'} . "\n";

	print 'quavered ngrams:     ' . $_hr_count->{'ngrams'}->{'quavered'}     . "\n";
	print 'quavered normalized: ' . $_hr_count->{'normalized'}->{'quavered'} . "\n";
	
	print 'snipa ngrams:     ' . $_hr_count->{'ngrams'}->{'snipa'}     . "\n";
	print 'snipa normalized: ' . $_hr_count->{'normalized'}->{'snipa'} . "\n";
	
	
	return $_hr_count;
}

sub slurp_text{
	
	my ($_fname)	= @_;
	
	my $_r_filein	= verify_and_read_file($_fname);
	if (not defined $_r_filein) {
		return;
	}

	#convert CRs and LFs into spaces
	$_r_filein =~ s/\r/\n/g;
	$_r_filein =~ s/\n/ /g;
	
	#apostrophes
	$_r_filein =~ s/’/\'/g;
	$_r_filein =~ s/‘/\'/g;
	
	#remove all chars except spaces and plain alphabetic
	#$_r_filein =~ s/[^a-zA-Z \'\’\-]+//g;
	$_r_filein =~ s/[^a-zA-Z \'\-]+//g;
	
	#they'd -> they
	$_r_filein =~ s/'d//g;
	
	#genitives
	$_r_filein =~ s/'s//g;

	#I'm
	$_r_filein =~ s/'m//g;

	#you/we/they're
	$_r_filein =~ s/'re//g;

	#hadn't -> had, wasn't -> was etc
	$_r_filein =~ s/n\'t//g;

	#leading apostrophes
	$_r_filein =~ s/ '/ /g;
	#trailing apostrophes
	$_r_filein =~ s/' / /g;	
	
	
	#delete apostrophes
	#$_r_filein =~ s/\'//g;
	#$_r_filein =~ s/\’//g;
	
	#convert plurals into singulars
	$_r_filein =~ s/s$//g;
	
	my @_a_filein	= split /\s+/, $_r_filein;
	
	
	if ($_remove_capitalized_words) {
		#remove words starting with upper case. Most are names
		@_a_filein = grep(!/^[A-Z]/, @_a_filein);
	}
#	p @_a_filein;
	
 	my $_hr_count	= word_counter(\@_a_filein);

 	print 'Found '. scalar ( keys %{$_hr_count->{'ngrams'}} ). " unique words in $_fname, total: $_hr_count->{'stats'}->{'wordcount'} \n";
 	
 	#write_ordered_output ($_fname,$_hr_count);
 	
 	$_hr_count	= normalizer($_hr_count);
 	
	return $_hr_count;
}


sub read_wordcount_file {
	#reads a txt file formatted as:
	#word occurrences
	
	my ($_fname)	= @_;
	my $_hr_count;
	
	my $_r_filein	= verify_and_read_file($_fname);
	if (not defined $_r_filein) {
		return;
	}
	
	#convert apostrophse into underscores
	#not necessary, hadn't is stored as hadnt
	#$_r_filein =~ s/\'/_/g;
	#$_r_filein =~ s/\’/_/g;
	
	#convert plurals into singulars
	$_r_filein =~ s/s$//g;
	
	#hadn't -> had, wasn't -> was etc
	$_r_filein =~ s/n\'t//g;
	$_r_filein =~ s/n’t//g;
	

	
	my @_a_filein	= split /\n+/, $_r_filein;
	my $_wordcount	= 0;
	
	foreach my $_line (@_a_filein) {
		
		my @_a_line	= split (/\s+/, $_line);
		if (not defined $_hr_count->{'ngrams'}->{$_a_line[0]}) {
			$_hr_count->{'ngrams'}->{$_a_line[0]}	= 0;
		}
		if (defined $_a_line[1]) {
			#plurals converted into singulars must be added
			$_hr_count->{'ngrams'}->{$_a_line[0]}	= $_hr_count->{'ngrams'}->{$_a_line[0]} + $_a_line[1];
			$_wordcount								= $_wordcount + $_a_line[1];
		}
		
	}
	
	$_hr_count->{'stats'}->{'wordcount'}	= $_wordcount;
	print 'Found '. scalar ( keys %{$_hr_count->{'ngrams'}} ). " unique words in $_fname, total: $_wordcount \n";

	$_hr_count	= normalizer($_hr_count);
	
	return $_hr_count;

}

sub match_vs_corpus {
	
	my ($_hr_corpus, $_hr_text, $_fname)	= @_;
	my $_fname_out			= $_fname.'_norm_matched';
	my $_fname_unmatched	= $_fname.'_unmatched';
	my $_unmatched			= 0;
	
	write_file ($_fname_out,{append =>0},'');
	write_file ($_fname_unmatched,{append =>0},'');		
	
	foreach my $_text_word (keys %{$_hr_text->{'normalized'}}) {
		
		if (defined $_hr_corpus->{'normalized'}->{$_text_word}) {
			
			my $_str_out	= 	$_text_word
								.' '.
								$_hr_corpus->{'normalized'}->{$_text_word}
								.' '.
								$_hr_text->{'normalized'}->{$_text_word}
								."\n";
			
			write_file ($_fname_out,{append =>1},$_str_out);
			
		} else {
			$_unmatched++;
			write_file ($_fname_unmatched,{append =>1},$_text_word."\n");
			#print $_unmatched .' '.$_text_word."\n";
		}
	}
	
	print $_unmatched .' unmatched '."\n";
	
}




















# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Text::WordFrequencyAnalyzer - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Text::WordFrequencyAnalyzer;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Text::WordFrequencyAnalyzer, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

rafd, E<lt>rafd@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 by rafd

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.22.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
