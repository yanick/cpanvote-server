package cpanvote::Controller::Votes;
use Moose;
use namespace::autoclean;

BEGIN {
    extends 'Catalyst::Controller::REST';
}

__PACKAGE__->config(
    map => {
        %{ __PACKAGE__->config->{'map'} },
        "text/javascript" => "JSONP",
    }
);


sub latest :Local :Args(0) :ActionClass('REST') {
}

sub latest_GET {
    my ( $self, $c ) = @_;

    my $rs = $c->model('cpanvoteDB::Votes')->search({},{
            limit => 100,
            order_by => { '-desc' => 'last_change' },
            prefetch => [ qw/ dist instead / ],
        });

    my @result;
    while ( my $v = $rs->next ) {
        my %data = ( 
            dist   => $v->dist->distname,
            user   => $v->user->username,
            'time' => $v->last_change->iso8601,
        );
        $data{vote} = $v->vote if defined $v->vote;
        $data{instead} = $v->instead->distname if defined $v->instead;
        push @result,  \%data;
    }

    $self->status_ok( $c, entity => \@result );
}

__PACKAGE__->meta->make_immutable;

1;

