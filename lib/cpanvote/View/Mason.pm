package cpanvote::View::Mason;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Mason';

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
