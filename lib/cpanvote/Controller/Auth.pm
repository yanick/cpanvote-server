package cpanvote::Controller::Auth;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

sub whoami :Local :ActionClass('REST') {
}

sub whoami_GET {
    my ( $self, $c ) = @_;

    my $id = $c->session->{user_id};
    my $user = $id && $c->model('cpanvoteDB::Users')->find({ id => $id });

    $c->stash->{user} = $user;

    if ( $c->req->header('Accept') =~ m#text/html# ) {
        $c->stash->{template} = 'auth/authenticated.mason';
        $c->forward( 'Mason' );
    } else {
        $user ? $self->status_ok( $c, entity => {
                username => $user->username
            } )
        : $self->status_not_found($c, message => 'not logged in' ); 
    }

}

sub test :Local {
    my ( $self, $c ) = @_;

    my $user = $c->model('cpanvoteDB::Users')->find_or_create({ 
        username => 'Tester',
    });

    $c->session->{user_id} = $user->id;

    $self->status_ok( $c, entity => {} );
}

sub twitter :Local {
    my ( $self, $c ) = @_;

    $c->session->{return_url} = $c->req->header('Referer');

    $c->res->redirect( 
        $c->get_auth_realm('twitter')->credential->authenticate_twitter_url($c) 
    );
}

sub twitter_callback :Path( 'twitter/callback' ) {
    my ($self, $c) = @_;

    my $twitter = $c->get_auth_realm('twitter')->credential;
    $twitter->authenticate_twitter( $c );

    my $tu = $twitter->twitter_user or return;

    my $auth = $c->model('cpanvoteDB::Auth')->find_or_create({
        'protocol'   => 'twitter',
        'credential' => $tu->{screen_name},
    } );

    my $username = $tu->{screen_name};
    unless ( $auth->user_id ) {
        # create new user...
            if ( $c->model('cpanvoteDB::Users')->find( { username => $username } ) ) {
                    $username .= '_0';
                    $username++
                      while $c>model('cpanvoteDB::Users')
                          ->find( { username => $username } );
                }

                my $u = $c->model('cpanvoteDB::Users')->create({ username => $username });
                $auth->user_id( $u->id );
                $auth->update;
            }

            $c->session->{user_id} = $auth->user_id;

    return $c->res->redirect( $c->session->{return_url} ) if $c->session->{return_url};

    $c->res->body( 'Hi there ' . $auth->user->username );

}

__PACKAGE__->meta->make_immutable;

1;
