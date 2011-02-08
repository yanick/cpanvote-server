package cpanvote::Controller::Register;

use Moose;
use namespace::autoclean;

BEGIN {
    extends 'Catalyst::Controller::REST';
}



sub index :Chained('/') :PathPart('register') :ActionClass('REST') :Args(0){
}

sub index_PUT {
    my ( $self, $c ) = @_;

    my $username = $c->req->data->{username};
    my $password = $c->req->data->{password};

    if ( $c->model('cpanvoteDB::Users')->find({username => $username }) ) {
        $self->status_bad_request( $c, message => "user '$username' already exist"
        );
        $c->detach;
    }

    $c->model('cpanvoteDB::Users')->create({ 
        username => $username, 
        password => $password });

    $self->status_accepted( $c, entity => { status => "user '$username' created" } );

}

__PACKAGE__->meta->make_immutable;
1;
