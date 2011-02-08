package cpanvote::Controller::Dist;
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

=head1 NAME

cpanvote::Controller::Dist - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub base : Chained('/') : PathPart('dist') : CaptureArgs(1) {
    my ( $self, $c, $distname ) = @_;

    $distname =~ s/::/-/g;

    $c->stash->{dist} = $c->model('cpanvoteDB::Distributions')
      ->find_or_create( { distname => $distname } );
}

sub instead :Chained('base') :PathPart('instead') :CaptureArgs(0) { }

sub instead_info :Chained('instead') :PathPart('') :ActionClass('REST')
:Args(0) {
}

sub instead_info_GET {
    my ( $self, $c ) = @_;

    my $rs = $c->stash->{dist}->votes->search(undef,{
            group_by => 'instead_id',
            select => [
                'instead_id',
                'count(instead_id)',
            ],
            as => [
                'instead_id',
                'count',
            ],
        });

    my @dists;

    while ( my $instead = $rs->next ) {
        my $name = $c->model('cpanvoteDB::Distributions')->find({ id =>
            $instead->instead_id })->distname;
        push @dists, {
                distname => $name,
                count => $instead->get_column('count'),
        };
    }

    $self->status_ok( $c, entity => {
            dists => \@dists,
        });
}

sub instead_edit :Chained('instead') :PathPart('use') :ActionClass('REST')
:Args(1) {
}

sub instead_edit_PUT {
    my ( $self, $c, $instead ) = @_;

    return $self->status_bad_request( $c, 
        message => 'you need to be logged in to vote' ) unless $c->session;

    my $v = $c->stash->{dist}->find_or_create_related( 'votes', {
            user_id => $c->session->{user_id},
        });

    my $instead_dist = $c->model('cpanvoteDB::Distributions')->find_or_create(
        { distname => $instead }
    );

    $v->instead( $instead_dist );

    $v->update;

    $self->status_ok( $c, entity => {
            message => 'success'
        });

}

sub votes :Chained('base') :PathPart('votes') :ActionClass('REST') :Args(0) {
}

sub votes_GET {
    my ( $self, $c ) = @_;

    my $votes = $c->stash->{dist}->votes;

    # TODO Group By instead of this...
    my ( $yea, $nea, $meh ) = (0,0,0);
    while ( my $v = $votes->next ) {
        if ( $v->vote == 1 ) {
            $yea++;
        }
        elsif ( $v->vote == -1 ) {
            $nea++;
        }
        else { $meh++ }
    }

    my %data = (
        yea => $yea,
        nea => $nea,
        meh => $meh,
        total => $yea + $meh + $nea,
    );

    if ( my $user_id = $c->session->{user_id} ) {
        my $v = $c->stash->{dist}->votes->find({ user_id => $user_id });

        $data{my_vote} = !$v            ? undef 
                       : $v->vote == -1 ? 'nea' 
                       : $v->vote == 1  ? 'yea' 
                       :                  'meh'
                       ;
    }

    $self->status_ok( $c, entity => \%data );
}

sub vote :Chained('base') :PathPart('vote') :ActionClass('REST') :Args(1) {
}

sub vote_PUT {
    my ( $self, $c, $vote ) = @_;

    return $self->status_bad_request( $c, 
        message => 'you need to be logged in to vote' ) unless $c->session;

    my %vote_score = (
        yea => 1,
        nea => -1,
        meh => 0,
    );

    return $self->status_bad_request( $c,
        message => "vote must be 'yea', 'nea' or 'meh'" ) 
        unless exists $vote_score{$vote};

    my $user = $c->model('cpanvoteDB::Users')->find({id =>
            $c->session->{user_id} });

    my $dist = $c->stash->{dist};

    my $v = $user->find_or_create_related( 'votes', { dist_id => $dist->id } );

    $v->vote( $vote_score{ $vote } );

    $v->update;

    $self->status_ok( $c, entity => {
            message => 'success',
        });
}

sub summary : Chained('base') : PathPart('summary') : ActionClass('REST') :
  Args(0) {
}

sub summary_GET {
    my ( $self, $c ) = @_;

    my $dist = $c->stash->{dist};

    my @points;    # 0 = neah, 1 = meh, 2 = yeah
    my @insteads;
    my @comments;

    for my $vote ( $dist->votes ) {
        $points[ $vote->vote + 1 ]++;
        push @insteads, $vote->instead_id;
        push @comments, $vote->comment;
    }

    my %data;
    $data{vote}{neah} = $points[0];
    $data{vote}{meh}  = $points[1];
    $data{vote}{yeah} = $points[2];
    $data{instead} =
      [ map { $_->distname }
          $c->model('cpanvoteDB::Distributions')
          ->search( { id => [ grep { defined } @insteads ] } ) ];
    $data{comments} = [ grep { defined } @comments ];

    $self->status_ok( $c, entity => \%data );
}

__PACKAGE__->meta->make_immutable;

1;

