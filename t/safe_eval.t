#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
use Text::Math::NumExp;
use feature qw/say/;
use utf8::all;
use Data::Dump qw/dump/;
use File::Touch;
use Test::File;

my $flagfile = 't/flagfile';
my $res = touch $flagfile;
fail("Could not touch file '$flagfile'") unless $res and -f $flagfile;

my $ne;

$ne = "unlink '$flagfile'";
solve($ne);
file_exists_ok($flagfile);

$ne = "qx{rm '$flagfile'}";
solve($ne);
file_exists_ok($flagfile);

$ne = "`rm '$flagfile'`";
solve($ne);
file_exists_ok($flagfile);

$ne = "eval{qx{rm '$flagfile'}}";
solve($ne);
file_exists_ok($flagfile);

$ne = qq{system "rm '$flagfile'"};
solve($ne);
file_exists_ok($flagfile);

unlink $flagfile;
