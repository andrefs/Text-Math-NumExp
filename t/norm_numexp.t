#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 6;
use Text::Math::NumExp;
use feature qw/say/;
use utf8::all;

my $txt = join '',<DATA>;
norm_numexp(\$txt,{x => 1});

like	($txt, qr/10\*1/,    "10 x 1   => 10*1" );
like	($txt, qr/11\*1\.1/, "11 × 1.1 => 11*1.1" );
like	($txt, qr/12\*1\.2/, "12 * 1.2 => 12*1.2" );

like	($txt, qr/20\^2/,    "20 ^ 2 => 20^2" );
like	($txt, qr/30\^3/,    "30(3)  => 30^3" );
like	($txt, qr/3\.4\*10\^11/, "3.4 × 1011 => 3.4*10^11" );

__DATA__
10 x 1
11 × 1.1
12 * 1.2
20 ^ 2
30(3)
3.4 × 1011
