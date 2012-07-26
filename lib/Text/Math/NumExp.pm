use 5.006;
use strict;
use warnings;
package Text::Math::NumExp;

#ABSTRACT: Text::Math::NumExp - Find numeric expressions in text.

use utf8::all;
use base 'Exporter';
our @EXPORT = (qw/ 	norm_numexp
					find_numexp
					find_numwords
					solve
				/);
use Lingua::EN::FindNumber;
use Scalar::Util qw/looks_like_number/;
use Safe;


=head1 SYNOPSIS

 use Text::Math::NumExp;
 
 my $text = "Light travels at 3x10[8] m/s."
 norm_numexp($text); 
 # "Light travels at 3x10^8 m/s."

 $text = "The program used for the ampliﬁcation was as follows: 
 		5 min at 94°C, followed by 50 cycles consisting of 30s 
		at 94°C, 30s at 62°C, and 30s at 72°C";

 find_numexp($text);

 # [ { length => 1, offset =>  54, text => 5,           value => 5     },
 #   { length => 2, offset =>  63, text => 94,          value => 94    },
 #   { length => 2, offset =>  81, text => 50,          value => 50    },
 #   { length => 9, offset => 105, text => "30s at 94", value => undef },
 #   { length => 9, offset => 119, text => "30s at 62", value => undef },
 #   { length => 9, offset => 137, text => "30s at 72", value => undef },
 # ] 
 
 $text = "One plus one equals two.";
 find_numwords($text);
 
 # [ { length => 3, offset =>  0, text => "One", value => 1 },
 #   { length => 3, offset =>  9, text => "one", value => 1 },
 #   { length => 3, offset => 20, text => "two", value => 2 },
 # ] 

=head1 DESCRIPTION

This module searches for numbers and numeric expressions in a text, including:

=over 4

=item - numbers (e.g 30.000, 3.4, -20)

=item - spelled-out numbers (e.g. "one million", "three")

=item - complex numeric expressions (e.g. 1.5x10^-5)

=back

=head1 SUBROUTINES/METHODS

=head2 find_numexp

Finds numeric expressions in text.

=cut

sub find_numexp {
	my ($text_or_ref,$options) = @_;
	my $text = (ref($text_or_ref) ? $$text_or_ref : $text_or_ref);


	my $str_offset = 0;
	my $numexps = [];

	my $w 		= qr{[A-Za-z\-]};    	# letter
	my $s		= qr{[ \t]};		# space excluding \n	
	my $x 		= qr{[^\s\d]};		# not a space nor a digit
	my $break 	= qr{\-fold|%|°C|,\s};		# common number-ending patterns
	my $end 	= qr{$break|,$};	#
	my $wgap 	= qr{$w+$s+$w+};	# gap between words
	my $punct	= qr{[:,\.!?\/]}; 	# punctuation

	while ($text =~ /
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
			(substr $text, $str_offset) =~ /\Q$ne\E/;
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
			my $value = solve($ne);
			push @$numexps, { 
					text 	=> $ne, 
					offset 	=> $offset, 
					length 	=> $length,
					value 	=> $value,
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
	my ($text_or_ref,$options) = @_;
	my $text = (ref($text_or_ref) ? $$text_or_ref : $text_or_ref);
	my $numbers = [];

	while($text =~ /($number_re)/g){
		my $text 	= $1;
		my $start 	= $-[0];
		my $end 	= $+[0];
		$end = ($start + $-[0]) if($text =~ s/\s+$//);
		my $value = numify($text);
		next unless looks_like_number($value);
		push @$numbers, { 
				text   => $text, 
				offset => $start,
				length => $end-$start,
				value  => $value,
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

=head2 solve

Returns the value of a numerical expression. Retuns undef if expression is not solvable.

=cut

sub solve {
	my ($ne,$options) = @_;
	$ne =~ s/\^/**/g;
	my $value;
	{
		local $SIG{__WARN__} = sub {};
		my ($cpt) = new Safe;
		$cpt->permit(qw(lt i_lt gt i_gt le i_le ge i_ge eq i_eq ne i_ne ncmp i_ncmp slt sgt sle sge seq sne scmp));
		$cpt->permit(qw(atan2 sin cos exp log sqrt rand srand));
		$value = $cpt->reval($ne);
	}
	return $value if looks_like_number($value);
	return;
}

=head2 norm_numexp

Normalizes common numerical expression patterns (including Unicode characters).

=cut

sub norm_numexp {
	my ($text_or_ref,$options) = @_;
	my $text = (ref($text_or_ref) ? $$text_or_ref : $text_or_ref);

	# 10 x 5 -> 10*5
	my $mult = qr{[x×*✖✕✱∗﹡＊]};
    $text =~ s/(\d)\s{1,2}?$mult\s{1,2}?(\d)/$1*$2/g;

    # 10 ^ 5 -> 10^5
    $text =~ s/(\d)\s{1,2}?\^\s{1,2}?(\d)/$1^$2/g;

    # 10(5)/10[5] -> 10^5
    $text =~ s/(\d)\((\d+)\)/$1^$2/g;
    $text =~ s/(\d)\[(\d+)\]/$1^$2/g;

	# Extreme options
	if ($options->{x}){
		# *1011 -> *10^11
		$text =~ s/(\d)[*]10(\d{2})/$1*10^$2/g;
	}

	if(ref($text_or_ref))	{	$$text_or_ref = $text;	}
	else 					{	return $text;			}
	return;
}



1;    # End of Text::Math::NumExp
