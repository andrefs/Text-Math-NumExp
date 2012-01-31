#!/usr/bin/env perl 

use strict; use warnings; use diagnostics;
use feature qw/say/;
use Data::Dump qw/dd/;

# open my $fh, '<', $ARGV[0] or die;
my $txt = join '', <>;

my $w 		= qr{[A-Za-z]};    	# letter
my $s		= qr{[ \t]};		# space excluding \n	
my $x 		= qr{[^\s\d]};		# not a space nor a digit
my $break 	= qr{%|°C|,\s};		# common number-ending patterns
my $end 	= qr{$break|,$};	#
my $wgap 	= qr{$w+$s+$w+};	# gap between words

my $offsets = find_numexp($txt);
#dd($offsets);

foreach my $item (sort { $a->{offset} <=> $b->{offset} } @$offsets) {
	say $item->{text};
}

sub find_numexp {
	my ($txt) = @_;
	my $str_offset = 0;
	my $numexps = [];

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

			$ne_offset+= $+[0]
				if $ne =~ s/^[A-Za-z\s]*\s+//;

			$ne =~ s/\s+[A-Za-z\s]*$//;
			next if $ne =~ /^\s*$/;
			next if $ne !~ /\d/;

			$offset = $ne_offset;
			push @$numexps,{ text => $ne, offset => $offset };
			$offset+= length $ne;
		}
	}
	return $numexps;
}


__END__

my $w = qr{[A-Za-z]};
my $end = qr{%|°C|,\s|\s*$w\s+$w};
my $x = qr{[^\s\d]};

# while($txt =~ /^(\S*?$w\s+)($w.*?)$/s){
# 	print "$1\n";
# 	$txt = $2;
# }

while ($txt =~ /(?:$w\s+$w$x*\s+|^)(.*?)$end\s*/g) {
	my $str = $1;
	next unless $str =~ /\d/;
	print "'$str'\n"
}


__END__
my $w = qr{[A-Za-z]};
my $x = qr{[^\s\d]};

# while($txt =~ /^(\S*?$w\s+)($w.*?)$/s){
# 	print "$1\n";
# 	$txt = $2;
# }

while ($txt =~ /$w\s+$w$x*\s+(.*?)\s+$x*$w\s+$w/g) {;
	my $str = $1;
	next unless $str =~ /\d/;
	print "'$str'\n"
}

