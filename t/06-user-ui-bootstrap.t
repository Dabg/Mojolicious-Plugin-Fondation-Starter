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

# ─── User list page ──────────────────────────────────────────────────────────

subtest 'GET /users' => sub {
    $t->get_ok('/users')
      ->status_is(200)
      ->element_exists('table', 'table element present');
};

# ─── Bootstrap layout on /users ──────────────────────────────────────────────

subtest 'Bootstrap on /users' => sub {
    $t->get_ok('/users')
      ->element_exists('nav.navbar', 'navbar present');
};

done_testing;
