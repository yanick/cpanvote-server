package cpanvote::Test::Mech;

use strict;
use warnings;

use Moose::Role;
use Test::Routine;
use Test::Routine::Util;

has mech => (
    is => 'ro',
    lazy => 1,
    default=> sub { 
        $_[0]->db;    
        my $mech = Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'cpanvote' );
        $mech->add_header( 'content-type' => 'application/json' );
        return $mech;
    },
);

sub authenticate_test {
    my $self = shift;

    $self->mech->get_ok( '/auth/test' );
}

1;



