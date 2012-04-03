use 5.006;
use strict;
use warnings;
package Text::Math::NIT;

#ABSTRACT: Text::Math::NIT - Find Numbers In Text.

use base 'Exporter';
our @EXPORT = (qw/ norm_numexp
				/);


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 norm_numexp

=cut

sub norm_numexp {
	my $txtref = $_[0];

	# 10 x 5 -> 10*5
    $$txtref =~ s/(\d)\s{1,2}?x\s{1,2}?(\d)/$1*$2/g;

    # 10 ^ 5 -> 10^5
    $$txtref =~ s/(\d)\s{1,2}?\^\s{1,2}?(\d)/$1^$2/g;

    # 10(5) -> 10^5
    $$txtref =~ s/(\d)\((\d+)\)/$1^$2/g;
}



1;    # End of Text::Math::NIT
