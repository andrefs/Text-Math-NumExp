#!/usr/bin/env perl 

use strict; use warnings;
use feature qw/say/;

# open my $fh, '<', $ARGV[0] or die;
my $txt = join '', <>;

my $w 		= qr{[A-Za-z]};    	# letter
my $s		= qr{[ \t]};		# space excluding \n	
my $x 		= qr{[^\s\d]};		# not a space nor a digit
my $break 	= qr{%|°C|,\s};		# common number-ending patterns
my $end 	= qr{$break|,$};	#
my $wgap 	= qr{$w+$s+$w+};	# gap between words

find_numexp($txt);

sub find_numexp {
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
		next unless $str =~ /\d/;
		foreach my $ne (split /\s*$break\s*/,$str){
			$ne =~ s/^[A-Za-z\s]*\s+//;
			$ne =~ s/\s+[A-Za-z\s]*$//;
			next if $ne eq '';
			next if $ne !~ /\d/;
			say "$ne";
		}
	}
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

