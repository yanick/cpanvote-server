package cpanvote::Test::DB;

use strict;
use warnings;

use Moose::Role;

has db => (
    is => 'ro',
    lazy => 1,
    default => sub {
        unlink 'db.sqlite';
        my $schema = cpanvote::Schema->connect( 'dbi:SQLite:dbname=db.sqlite' );
        $schema->deploy;
        return $schema;
    },
);

before mech => sub {
    # we want to bring the db to life
    # before we start the application
    $_[0]->db;  
};

1;



