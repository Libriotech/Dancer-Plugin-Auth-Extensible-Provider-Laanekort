use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Dancer::Plugin::Auth::Extensible::Provider::Laanekort',
    AUTHOR           => q{Magnus Enger <magnus@enger.priv.no>},
    VERSION_FROM     => 'lib/Dancer/Plugin/Auth/Extensible/Provider/Laanekort.pm',
    ABSTRACT_FROM    => 'lib/Dancer/Plugin/Auth/Extensible/Provider/Laanekort.pm',
    LICENSE          => 'GPL_3',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Dancer-Plugin-Auth-Extensible-Provider-Laanekort-*' },
);
