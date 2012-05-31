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
  { length => 4, offset => 0, text => "10*1" },
  { length => 6, offset => 5, text => "11*1.1" },
  { length => 6, offset => 12, text => "12*1.2" },
  { length => 4, offset => 19, text => "20^2" },
  { length => 4, offset => 24, text => "30^3" },
  { length => 9, offset => 29, text => "3.4*10^11" },
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
