package Text::Math::NIT;

use 5.006;
use strict;
use warnings;

=head1 NAME

Text::Math::NIT - The great new Text::Math::NIT!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use base 'Exporter';
our @EXPORT = (qw/norm_numexp/);

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Text::Math::NIT;

    my $foo = Text::Math::NIT->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

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

=head2 find_numexp

=cut

sub find_numexp {
	my $txt = ${$_[0]};
	my $hash = {};


	my $num     = qr/[+\-]?\d+(?:[\.,]\d+)?/; # number (integer or decimal)
	my $nl      = qr/[^A-Za-z]/;
	my $extnum  = qr/$nl*$dec$nl*/;


}

=head1 AUTHOR

Andre Santos, C<< <andrefs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-math-nit at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Math-NIT>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Math::NIT


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Math-NIT>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Math-NIT>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Math-NIT>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Math-NIT/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Andre Santos.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Text::Math::NIT
