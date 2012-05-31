use 5.006;
use strict;
use warnings;
package Text::Math::NumExp;

#ABSTRACT: Text::Math::NumExp - Find Numbers In Text.

use utf8::all;
use base 'Exporter';
our @EXPORT = (qw/ 	norm_numexp
					find_numexp
					find_numwords
				/);
use Lingua::EN::FindNumber;


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

	while ($txt =~ /
						(?:
							$wgap		# word gap
							$x*			# remaning characters before numexp
							\s+			# space
						|
							^			# or begining of line
						)
						(.*?) 		# numexp
						(?=			# do not consume
							\s+			# space
							$wgap		# word gap
						|
							$			# or end of line
						)
					/mgxp) {
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

			next if _ignore($ne,$options);

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

=head2 find_numwords

Finds spelled-out numbers in text.

=cut

sub find_numwords {
	my ($txt,$options) = @_;
	my $numbers = [];

	while($txt =~ /($number_re)/g){
		push @$numbers, { 
				text   => $1, 
				offset => $-[0],
				length => $+[0]-$-[0],
				value  => numify($1),
			};
	}
	return wantarray ? @$numbers : $numbers;
}

sub _ignore {
	my ($ne, $options) = @_;
	# Ignore if string is empty or blank
	return 1 if $ne =~ /^\s*$/;

	# Ignore if string doesn't have a digit
	return 1 if $ne !~ /\d/;

	return 1 if $options->{ipat}  and $ne =~ /$options->{ipat}/;
	return 1 if $options->{ifunc} and $options->{ifunc}->($ne);

	return;
}


=head2 norm_numexp

Normalizes common numeric expression patterns (including Unicode characters).

=cut

sub norm_numexp {
	my ($txtref,$options) = @_;

	# 10 x 5 -> 10*5
	my $mult = qr{[x×*✖✕✱∗﹡＊]};
    $$txtref =~ s/(\d)\s{1,2}?$mult\s{1,2}?(\d)/$1*$2/g;

    # 10 ^ 5 -> 10^5
    $$txtref =~ s/(\d)\s{1,2}?\^\s{1,2}?(\d)/$1^$2/g;

    # 10(5) -> 10^5
    $$txtref =~ s/(\d)\((\d+)\)/$1^$2/g;

	# Extreme options
	if ($options->{x}){
		# *1011 -> *10^11
		$$txtref =~ s/(\d)[*]10(\d{2})/$1*10^$2/g;
	}
}



1;    # End of Text::Math::NumExp
