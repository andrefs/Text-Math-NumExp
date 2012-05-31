#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;
use Text::Math::NumExp;
use feature qw/say/;
use utf8::all;
use Data::Dump qw/dump/;

my $txt = join '',<DATA>;
norm_numexp(\$txt,{x => 1, ipat => qr/^\s*\[\d{1,2}\]|\(\d{1,2}\)\s*$/});
my $got = find_numexp($txt,{x => 1, ipat => qr/^\s*\[\d{1,2}\]|\(\d{1,2}\)\s*$/});

my $expected = [
	{ length => 4, offset => 0,  text => "10*1",      value => 10           },
	{ length => 6, offset => 5,  text => "11*1.1",    value => 12.1         },
	{ length => 6, offset => 12, text => "12*1.2",    value => 14.4         },
	{ length => 4, offset => 19, text => "20^2",      value => 400          },
	{ length => 4, offset => 24, text => "30^3",      value => 27000        },
	{ length => 9, offset => 29, text => "3.4*10^11", value => 340000000000 },
	{ length => 7, offset => 87, text => "4 ( 3,5",   value => undef        }
];

cmp_set($got,$expected,'Testing elements found in find_numexp');


__DATA__
10 x 1
11 × 1.1
12 * 1.2
20 ^ 2
30(3)
3.4 × 1011
bib reference [5]
bib reference (6)
unsolvable: 4 ( 3,5
