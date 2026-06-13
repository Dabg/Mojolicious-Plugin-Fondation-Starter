#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use FindBin;

use lib "$FindBin::Bin/../lib";

use_ok 'Mojolicious::Plugin::Fondation::Starter';

# ═══════════════════════════════════════════════════════════════════════════
# 1. fondation_meta structure
# ═══════════════════════════════════════════════════════════════════════════

subtest 'fondation_meta structure' => sub {
    my $meta = Mojolicious::Plugin::Fondation::Starter->fondation_meta;
    isa_ok($meta, 'HASH');

    ok(exists $meta->{defaults},             'defaults key exists');
    ok(exists $meta->{defaults}{dependencies}, 'dependencies key exists');
    is(ref $meta->{defaults}{dependencies}, 'ARRAY', 'dependencies is an array');
};

# ═══════════════════════════════════════════════════════════════════════════
# 2. Default dependencies contain expected plugins
# ═══════════════════════════════════════════════════════════════════════════

subtest 'Default dependencies' => sub {
    my $meta = Mojolicious::Plugin::Fondation::Starter->fondation_meta;
    my @deps = @{ $meta->{defaults}{dependencies} };

    my @names;
    for my $dep (@deps) {
        if (ref $dep eq 'HASH') {
            push @names, (keys %$dep)[0];
        }
        else {
            push @names, $dep;
        }
    }

    # Helper: match short or long name (Fondation resolves both)
    sub _has_dep {
        my ($names, $short) = @_;
        my $long = "Mojolicious::Plugin::$short";
        return (grep { $_ eq $short || $_ eq $long } @$names) ? 1 : 0;
    }

    ok(_has_dep(\@names, 'Fondation::Model::DBIx::Async'),       'DBIx::Async in dependencies');
    ok(_has_dep(\@names, 'Fondation::MigrationDBIx'),            'MigrationDBIx in dependencies');
    ok(_has_dep(\@names, 'Fondation::User'),                     'User in dependencies');
    ok(_has_dep(\@names, 'Fondation::Auth'),                     'Auth in dependencies');
    ok(_has_dep(\@names, 'Fondation::Layout::Bootstrap'),        'Layout::Bootstrap in dependencies');
    ok(_has_dep(\@names, 'Fondation::User::UI::Bootstrap'),      'User::UI::Bootstrap in dependencies');
    ok(_has_dep(\@names, 'Fondation::Asset'),                    'Asset in dependencies');
    ok(_has_dep(\@names, 'Fondation::OpenAPI'),                  'OpenAPI in dependencies');
    ok(_has_dep(\@names, 'Fondation::I18N'),                     'I18N in dependencies');
};

done_testing;
