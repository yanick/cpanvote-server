#!/usr/bin/perl 

use strict;
use warnings;


use cpanvote::Schema;

use 5.010;

my $schema = cpanvote::Schema->connect( 'dbi:SQLite:dbname=db.sqlite' );


sub do_them_all {

my $dists = $schema->resultset('Distributions');

my %tags;
while ( my $d = $dists->next ) {
    $tags{$_}++ for $d->tagnames;
}

my @keys = sort { $tags{$a} <=> $tags{$b} } keys %tags;

say "$_ $tags{$_}" for @keys;

}

say $_->distname for dists_with_tags( $schema, 'catalyst', 'view', 'xml' );

#my %tags = make_cloud( [ $schema->resultset('Tags')->search({name =>
#            'catalyst'})->search_related('disttags')->search_related('dist')
#   ], [ qw/ catalyst / ] );

#my @keys = sort { $tags{$a} <=> $tags{$b} } keys %tags;

#say "$_ $tags{$_}" for @keys;

sub make_cloud {
    my @dists = @{$_[0]};
    my @remove = ref $_[1] ? @{$_[1]} : ();

    my %tags;
    for my $d ( @dists ) {
        $tags{$_}++ for $d->tagnames;
    }

    delete $tags{$_} for @remove;

    return %tags;
}


sub dists_with_tags {
    my $schema = shift;
    my @tags = @_;

    unless ( @tags ) {
        return $schema->resulset('Distributions')->all;
    }

    @tags = sort @tags;

    # first one is seeding the dists
    my $tag = shift @tags;

    use List::MoreUtils qw/ uniq /;

    my @dists = uniq map { $_->dist_id } 
        $schema->resultset('Tags')->search({name=>$tag})->search_related('disttags');

   while ( my $tag = shift @tags ) {
       return unless @dists;

       my @tag_ids = map { $_->id }
       $schema->resultset('Tags')->search({name=>$tag});

       @dists = uniq map { $_->dist_id } 
        $schema->resultset('TagDist')->search({ tag_id => \@tag_ids, dist_id =>
           \@dists });
   }

   return $schema->resultset('Distributions')->search({id=>\@dists})->all;

}


    
