#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Text::Math::NIT' ) || print "Bail out!\n";
}

diag( "Testing Text::Math::NIT $Text::Math::NIT::VERSION, Perl $], $^X" );
