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

# ─── Login page ──────────────────────────────────────────────────────────────

subtest 'GET /login' => sub {
    $t->get_ok('/login')
      ->status_is(200)
      ->element_exists('form', 'login form present');
};

# ─── Login with wrong password ───────────────────────────────────────────────

subtest 'POST /login wrong password' => sub {
    $t->post_ok('/login' => form => { username => 'admin', password => 'wrong' })
      ->status_is(302, 'redirect on failure')
      ->header_like(Location => qr{/login}, 'redirects back to /login');
};

# ─── Login with correct credentials ──────────────────────────────────────────

subtest 'POST /login correct credentials' => sub {
    $t->post_ok('/login' => form => { username => 'admin', password => 'pass' })
      ->status_is(302, 'redirect on success')
      ->header_like(Location => qr{/$}, 'redirects to /');
};

# ─── current_user after login ────────────────────────────────────────────────

subtest 'current_user after login' => sub {
    # Already logged in from previous subtest (cookie jar persists)
    $t->get_ok('/')
      ->status_is(200);

    my $c = $t->app->build_controller;
    $c->tx($t->tx);
    my $user = $c->current_user;
    ok($user, 'current_user defined');
    is($user->{username}, 'admin', 'current_user username is admin');
};

# ─── Logout ──────────────────────────────────────────────────────────────────

subtest 'GET /logout' => sub {
    $t->get_ok('/logout')
      ->status_is(302, 'logout redirects')
      ->header_like(Location => qr{/$}, 'redirects to / after logout');

    # Verify current_user is gone after logout
    $t->get_ok('/')
      ->status_is(200);
    my $c = $t->app->build_controller;
    $c->tx($t->tx);
    ok(!$c->current_user, 'current_user undefined after logout');
};

# ─── Login page accessible again after logout ────────────────────────────────

subtest 'login accessible after logout' => sub {
    $t->get_ok('/login')
      ->status_is(200, 'login page accessible after logout');
};

# ─── Login works again after logout ──────────────────────────────────────────

subtest 'login works after logout' => sub {
    $t->post_ok('/login' => form => { username => 'admin', password => 'pass' })
      ->status_is(302, 'login succeeds after logout')
      ->header_like(Location => qr{/$}, 'redirects to /');
};

done_testing;
