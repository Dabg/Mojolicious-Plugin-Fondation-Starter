#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Mojo;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use StarterTestHelper qw(build_app);

my ($app, $t, $tempdir) = build_app();

# ─── Registry page accessible ────────────────────────────────────────────────

subtest 'GET /fondation/registry' => sub {
    $t->get_ok('/fondation/registry')
      ->status_is(200);
};

# ─── Lists loaded plugins ────────────────────────────────────────────────────

subtest 'lists plugins' => sub {
    $t->get_ok('/fondation/registry')
      ->content_like(qr/Fondation::User/,   'User plugin listed')
      ->content_like(qr/Fondation::Group/,  'Group plugin listed')
      ->content_like(qr/Fondation::Auth/,   'Auth plugin listed');
};

done_testing;
