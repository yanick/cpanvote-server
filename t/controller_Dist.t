use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'cpanvote' }
BEGIN { use_ok 'cpanvote::Controller::Dist' }

ok( request('/dist')->is_success, 'Request should succeed' );
done_testing();
