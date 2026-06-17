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

# ─── GET / returns 200 ───────────────────────────────────────────────────────

subtest 'GET /' => sub {
    $t->get_ok('/')->status_is(200);
};

# ─── Bootstrap layout elements ───────────────────────────────────────────────

subtest 'Bootstrap navbar' => sub {
    $t->get_ok('/')
      ->element_exists('nav.navbar', 'navbar present');
};

subtest 'Bootstrap container' => sub {
    $t->get_ok('/')
      ->element_exists('div.container, div.container-fluid', 'container present');
};

# ─── Title ───────────────────────────────────────────────────────────────────

subtest 'page title' => sub {
    $t->get_ok('/')
      ->element_exists('head title', 'title tag present');
};

done_testing;
