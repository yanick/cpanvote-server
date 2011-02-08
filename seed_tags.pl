#!/usr/bin/perl 

use strict;
use warnings;

use cpanvote::Schema;

use 5.010;

my $schema = cpanvote::Schema->connect( 'dbi:SQLite:dbname=db.sqlite' );

my $dists = $schema->resultset('Distributions');

while( my $d = $dists->next ) {
    say my $name = $d->distname;
    my @tags = split '-', $name;

    for ( @tags ) {
        my $tag = $schema->resultset( 'Tags' )->find_or_create( {
                user_id => undef,
                name => lc $_,
            }
        );
        $d->find_or_create_related( 'disttags', { 
           tag_id => $tag->id,
       } );
    }
}
    
