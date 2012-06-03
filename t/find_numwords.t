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
my $got = find_numwords($txt);

my $expected = [
  { length => 4,  offset => 60,  text => "four",         value => "4"    },
  { length => 3,  offset => 216, text => "two",          value => "2"    },
  { length => 3,  offset => 373, text => "one",          value => "1"    },
  { length => 6,  offset => 403, text => "twenty",       value => "20"   },
  { length => 4,  offset => 432, text => "five",         value => "5"    },
  { length => 12, offset => 456, text => "Two thousand", value => "2000" },
];

cmp_set($got,$expected,'Testing elements found in find_numwords');

__DATA__

Surveys of cloned rRNA genes from the enrichments revealed four major strains of AOB which were phylogenetically related to the Nitrosomonas marina cluster.

Utilizing the principle of competitive PCR, we developed two assays to enumerate Nitrosomonas oligotropha-like ammonia-oxidizing bacteria and nitrite-oxidizing bacteria belonging to the genus NITROSPIRA.

And just one more random sentence with twenty or so words, in which five or more are short. Two thousand is a big number.
