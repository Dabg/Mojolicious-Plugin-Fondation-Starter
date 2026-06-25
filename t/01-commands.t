#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;

use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/lib";

use StarterTestHelper qw(build_app);

use_ok 'Mojolicious::Plugin::Fondation::Starter';

# ═══════════════════════════════════════════════════════════════════════════
# 1. fondation_meta structure
# ═══════════════════════════════════════════════════════════════════════════

subtest 'fondation_meta structure' => sub {
    my $meta = Mojolicious::Plugin::Fondation::Starter->fondation_meta;
    isa_ok($meta, 'HASH');

    ok(exists $meta->{defaults},     'defaults key exists');
    ok(exists $meta->{dependencies}, 'dependencies key exists');
    is(ref $meta->{dependencies}, 'ARRAY', 'dependencies is an array');
};

# ═══════════════════════════════════════════════════════════════════════════
# 2. Plugins actually loaded — registry check
# ═══════════════════════════════════════════════════════════════════════════

subtest 'Plugins loaded in registry' => sub {
    my ($app, $t, $tempdir) = build_app();

    my $registry = $app->fondation->registry;

    # Helper: plugin loaded if its long name is a key in the registry
    my $_loaded = sub {
        my ($short) = @_;
        my $long = "Mojolicious::Plugin::$short";
        return exists $registry->{$long};
    };

    # Direct dependencies
    ok($_loaded->('Fondation::Model::DBIx::Async'),   'DBIx::Async loaded');
    ok($_loaded->('Fondation::MigrationDBIx'),          'MigrationDBIx loaded');
    ok($_loaded->('Fondation::User'),                   'User loaded');
    ok($_loaded->('Fondation::Auth'),                   'Auth loaded');
    ok($_loaded->('Fondation::Group'),                  'Group loaded');
    ok($_loaded->('Fondation::Layout::Bootstrap'),      'Layout::Bootstrap loaded');
    ok($_loaded->('Fondation::User::UI::Bootstrap'),    'User::UI::Bootstrap loaded');
    ok($_loaded->('Fondation::Group::UI::Bootstrap'),   'Group::UI::Bootstrap loaded');
    ok($_loaded->('Fondation::Asset'),                  'Asset loaded');
    ok($_loaded->('Fondation::OpenAPI'),                'OpenAPI loaded');
    ok($_loaded->('Fondation::I18N'),                   'I18N loaded');
    ok($_loaded->('Fondation::Devel'),                  'Devel loaded');
};

done_testing;
