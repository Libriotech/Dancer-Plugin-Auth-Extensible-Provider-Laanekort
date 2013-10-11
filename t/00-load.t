#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Dancer::Plugin::Auth::Extensible::Provider::Laanekort' ) || print "Bail out!\n";
}

diag( "Testing Dancer::Plugin::Auth::Extensible::Provider::Laanekort $Dancer::Plugin::Auth::Extensible::Provider::Laanekort::VERSION, Perl $], $^X" );
