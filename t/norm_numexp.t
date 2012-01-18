#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;
use Text::Math::NIT;

my $txt = join '',<DATA>;
norm_numexp(\$txt);

like	($txt, qr/10\*1/, "10 x 1 => 10*1" );
like	($txt, qr/20\^2/, "20 ^ 2 => 20^2" );
like	($txt, qr/30\^3/, "30(3)  => 30^3" );

__DATA__
10 x 1
20 ^ 2
30(3)
