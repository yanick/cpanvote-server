package cpanvote::Test::Votes;

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

test "/votes/latest" => sub {
    my $self = shift;

    my $mech = $self->mech;

    $mech->get_ok( "/votes/latest" );

    my $votes = from_json( $mech->content );

    diag explain $votes;

};

run_me();
