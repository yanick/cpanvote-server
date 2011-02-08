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
use List::MoreUtils qw/ any first_value /;

use Moose::Role;

with qw/ 
    cpanvote::Test::DB 
    cpanvote::Test::Mech 
/;

before run_test => sub {
    $_[0]->authenticate_test;   
};

test "/dist/Foo/vote" => sub {
    my $self = shift;

    my $mech = $self->mech;

    my $dist = 'Foo-Bar';

    $mech->put_ok( "/dist/$dist/vote/yea" );

    $mech->get_ok( "/dist/$dist/votes" );

    my $votes = from_json( $mech->content );

    is $votes->{my_vote} => 'yea';

    is $votes->{yea} => 1;
};

test '/dist/Foo/instead' => sub {
    my $self = shift;

    my $mech = $self->mech;

    my $dist = 'Foo-Bar';

    $mech->put_ok( "/dist/$dist/instead/use/Other-Dist" );

    $mech->get_ok( "/dist/$dist/instead" );

    my $instead = from_json( $mech->content );

    my $other = first_value
                    { $_->{distname} eq 'Other-Dist' } 
                    @{ $instead->{dists} };

    ok $other, 'Other-Dist is present';

    is $other->{count} => 1, 'with one recommendation';
};

run_me();
done_testing;
