package cpanvote;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use Catalyst qw/
    ConfigLoader
    Static::Simple
    Authentication
    Cache
    Session
    Session::Store::DBIC
    Session::State::Cookie
    Session::PerUser
/;

extends 'Catalyst';

our $VERSION = '0.2.0';
$VERSION = eval $VERSION;

__PACKAGE__->config(
    name => 'cpanvote',
    default_view => 'mason',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    authentication => {
        default_realm => 'twitter',
        realms => { 
            twitter => {
                credential => { 
                    class => 'Twitter',
                },
                consumer_key    => 'secret',
                consumer_secret => 'secret',
                callback_url    => 'http://enkidu:3000/auth/twitter/callback',
                store => {
                    class => 'DBIx::Class',
                    user_model => 'cpanvoteDB::AuthTwitter',
                },
            },
        },
    },
    'Plugin::Session' => {
        dbic_class => 'cpanvoteDB::Sessions',
        expires => 60 * 60 * 24 * 30,  # 30 days
    },
);

__PACKAGE__->config->{'Plugin::Cache'}{backend} = {
    class   => "Cache::Memory",
};

# Start the application
__PACKAGE__->setup();


sub finalize_config { 
    my $self = shift;   
# twitter config
my $twitter = $self->config->{twitter};
my $t = $self->config->{authentication}{realms}{twitter};

$t->{consumer_key} = $twitter->{key};
$t->{consumer_secret} = $twitter->{secret};
$t->{callback_url} = $twitter->{callback_url};
}


=head1 NAME

cpanvote - Catalyst based application

=head1 SYNOPSIS

    script/cpanvote_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<cpanvote::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Yanick Champoux,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
