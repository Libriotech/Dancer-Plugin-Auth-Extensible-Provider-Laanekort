package Dancer::Plugin::Auth::Extensible::Provider::Laanekort;

use base 'Dancer::Plugin::Auth::Extensible::Provider::Base';
use Dancer qw(:syntax);
use SOAP::Lite;
use Modern::Perl;
use Data::Dumper; # FIXME

BEGIN {
    sub SOAP::Transport::HTTP::Client::get_basic_credentials {
        return config->{'laanekort_username'} => config->{'laanekort_password'};
    }
}

=head1 NAME

Dancer::Plugin::Auth::Extensible::Provider::Laanekort - Authentication against "Nasjonalt lånekort"

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Provides autentication for Dancer apps against the Norwegian "Nasjonalt lånekort" library patron database. 

=head1 SUBROUTINES/METHODS

=head2 authenticate_user

Given the username and password entered by the user, return true if they are
authenticated, or false if not.

=cut

sub authenticate_user {

    my ($self, $patron_username, $patron_password) = @_;
    
    # TODO Validate the format of the username and the password/pin code
    
    my $settings = $self->realm_settings;
    
    my $client = SOAP::Lite
	    ->on_action( sub { return '""';})
	    ->uri('http://lanekortet.no')
	    ->proxy('https://fl.lanekortet.no/laanekort/bs_flnr.php');
	    
    debug "=== Attempting login against NL: " . $patron_username . " " . $settings->{'bibnr'} . " " . $patron_password;

    my $lnr = SOAP::Data->type('string');
    $lnr->name('lnr');
    $lnr->value( $patron_username );

    my $bibnr = SOAP::Data->type('string');
    $bibnr->name('bibnr');
    $bibnr->value( $settings->{'bibnr'} );

    my $pin = SOAP::Data->type('string');
    $pin->name('pin');
    $pin->value( $patron_password );

    my $result = $client->verifyLnr( $lnr, $bibnr, $pin );

    unless ($result->fault) {

	    my $user = $result->result();
	    debug Dumper $result->result();
    	return $user->{'status'};

    } else {

	    debug join ', ',
		    $result->faultcode,
		    $result->faultstring,
		    $result->faultdetail;
	    return 0;

    }
    
}

=head2 get_user_details

Given a username, return details about the user. 

Details are returned as a hashref.

=cut

sub get_user_details {

    my ($self, $patron_username) = @_;
    
    my $settings = $self->realm_settings;
    debug "*** Getting user details from NL";
    
    my $client = SOAP::Lite
	    ->on_action( sub { return '""';})
	    ->uri( 'http://lanekortet.no' )
	    ->proxy( 'https://fl.lanekortet.no/laanekort/fl.php' );

    my $lnr = SOAP::Data->type( 'string' );
    $lnr->name( 'identifikator' );
    $lnr->value( $patron_username );

    my $result = $client->hent( $lnr );

    unless ($result->fault) {

        my $r = $result->result();
        if ( $r->{'antall_poster_returnert'} != 1 ) {
            # FIXME What to do? 
            debug "*** Got antall_poster_returnert != 1";
        } else {
        	my $patron = $r->{'respons_poster'}[0];
        	my $user = {};
        	$user->{email}    = $patron->{'epost'};
            $user->{name}     = $patron->{'navn'};
            $user->{gender}   = $patron->{'kjonn'};
            $user->{birthday} = $patron->{'fdato'};
            $user->{zipcode}  = $patron->{'p_postnr'};
            $user->{place}    = $patron->{'p_sted'};
            return $user
        }

    } else {

	    debug join ', ',
		    $result->faultcode,
		    $result->faultstring,
		    $result->faultdetail;

    }
            
}

=head2 get_user_roles

Given a username, return a list of roles that user has.

=cut

sub get_user_roles {
    my @roles = ( 'nluser' );
    return \@roles;
}


=head1 AUTHOR

Magnus Enger, C<< <magnus at enger.priv.no> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-plugin-auth-extensible-provider-laanekort at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Plugin-Auth-Extensible-Provider-Laanekort>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::Auth::Extensible::Provider::Laanekort


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Plugin-Auth-Extensible-Provider-Laanekort>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Plugin-Auth-Extensible-Provider-Laanekort>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-Auth-Extensible-Provider-Laanekort>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Plugin-Auth-Extensible-Provider-Laanekort/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Magnus Enger.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.


=cut

1; # End of Dancer::Plugin::Auth::Extensible::Provider::Laanekort
