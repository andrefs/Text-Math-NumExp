use 5.006;
use strict;
use warnings;
package Text::Math::NumExp;

#ABSTRACT: Text::Math::NumExp - Find Numbers In Text.

use base 'Exporter';
our @EXPORT = (qw/ 	norm_numexp
					find_numexp
				/);


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 find_numexp

Finds numeric expressions in text.

=cut

sub find_numexp {
	my ($txt,$options) = @_;
	my $str_offset = 0;
	my $numexps = [];

	my $w 		= qr{[A-Za-z\-]};    	# letter
	my $s		= qr{[ \t]};		# space excluding \n	
	my $x 		= qr{[^\s\d]};		# not a space nor a digit
	my $break 	= qr{\-fold|%|°C|,\s};		# common number-ending patterns
	my $end 	= qr{$break|,$};	#
	my $wgap 	= qr{$w+$s+$w+};	# gap between words
	my $punct	= qr{[:,\.!?\/]}; 	# punctuation

	while ($txt =~ /	$wgap		# word gap
						$x*			# remaning characters before numexp
						\s+			# space
						(.*?) 		# numexp
						(?=			# do not consume
							\s+			# space
							$wgap		# word gap
							|$
						)
					/gxp) {
		my $str = $1;
		$str_offset = $-[1];
		next unless $str =~ /\d/;
		my $offset = $str_offset;

		foreach my $ne (split /\s*$break\s*/,$str){
			(substr $txt, $str_offset) =~ /\Q$ne\E/;
			my $ne_offset = $str_offset + $-[0];

			# Remove (partial) word, punctuation or space at the begining
			$ne_offset+= $+[0]
				if $ne =~ s/^(?:[A-Za-z\s\-]|$punct)*\s+//;

			# Remove punctuation at the end
			$ne =~ s/$punct*$//;

			# Remove space followed by word chars or punctuation at the end
			$ne =~ s/\s+(?:[A-Za-z\s]|$punct)*$//;


			# Remove single '(' at the begining if there is no closing ')'
			$ne_offset+= $+[0]
				if $ne !~ /\)/ and $ne =~ s/^\(//;

			# Remove single ')' at the begining if there is no opening '('
			$ne =~ s/\)$// if $ne !~ /\(/;

			# Ignore if string is empty or blank
			next if $ne =~ /^\s*$/;

			# Ignore if string doesn't have a digit
			next if $ne !~ /\d/;


			$offset = $ne_offset;
			my $length = length($ne);
			push @$numexps, { 
					text => $ne, 
					offset => $offset, 
					length => $length 
				};
			$offset+= length $ne;
		}
	}
	return wantarray ? @$numexps : $numexps;
}


=head2 norm_numexp

=cut

sub norm_numexp {
	my $txtref = $_[0];

	# 10 x 5 -> 10*5
    $$txtref =~ s/(\d)\s{1,2}?x\s{1,2}?(\d)/$1*$2/g;

    # 10 ^ 5 -> 10^5
    $$txtref =~ s/(\d)\s{1,2}?\^\s{1,2}?(\d)/$1^$2/g;

    # 10(5) -> 10^5
    $$txtref =~ s/(\d)\((\d+)\)/$1^$2/g;
}



1;    # End of Text::Math::NumExp
