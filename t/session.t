package cpanvote::Test::session;

use strict;
use warnings;

use Test::More;
use Test::Routine;
use Test::Routine::Util;
use Test::WWW::Mechanize::Catalyst;
use autodie;
use cpanvote::Schema;
use JSON;

use Moose::Role;

with qw/ 
    cpanvote::Test::DB 
    cpanvote::Test::Mech 
/;


test "user without session" => sub {
    my $self = shift;

    my $mech = $self->mech;

    $mech->get( '/auth/whoami' );

    is $mech->status => 404, 'not logged in';
};

test "user with valid session"  => sub {
    my $self = shift;

    my $mech = $self->mech;

    $mech->get_ok( '/auth/test' );
    
    $mech->get_ok( '/auth/whoami' );

    my $resp = from_json( $mech->content );

    is $resp->{username} => 'Tester';
};

run_me();
done_testing;
