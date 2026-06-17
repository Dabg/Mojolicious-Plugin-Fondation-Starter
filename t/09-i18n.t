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

# ─── Translation files exist ─────────────────────────────────────────────────

subtest 'translation files' => sub {
    ok(-f $app->home->child('share', 'i18n', 'fr.json'),
        'share/i18n/fr.json exists');
    ok(-f $app->home->child('share', 'i18n', 'en.json'),
        'share/i18n/en.json exists');
};

# ─── French translation ──────────────────────────────────────────────────────

subtest 'French translation' => sub {
    $t->get_ok('/login' => { 'Accept-Language' => 'fr' })
      ->status_is(200)
      ->content_like(qr/Connexion/, 'page shows French "Connexion"');
};

# ─── English translation ─────────────────────────────────────────────────────

subtest 'English translation' => sub {
    $t->get_ok('/login' => { 'Accept-Language' => 'en' })
      ->status_is(200)
      ->content_like(qr/Sign in/, 'page shows English "Sign in"');
};

done_testing;
