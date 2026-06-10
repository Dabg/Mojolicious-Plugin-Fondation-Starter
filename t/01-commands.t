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

    ok((grep { $_ eq 'Fondation::Model::DBIx::Async' } @names),    'DBIx::Async in dependencies');
    ok((grep { $_ eq 'Fondation::MigrationDBIx' } @names),         'MigrationDBIx in dependencies');
    ok((grep { $_ eq 'Fondation::User' } @names),                  'User in dependencies');
    ok((grep { $_ eq 'Mojolicious::Plugin::Fondation::Layout::Bootstrap' } @names),
        'Layout::Bootstrap in dependencies');
    ok((grep { $_ eq 'Mojolicious::Plugin::Fondation::User::UI::Bootstrap' } @names),
        'User::UI::Bootstrap in dependencies');
    ok((grep { $_ eq 'Mojolicious::Plugin::Fondation::Asset' } @names), 'Asset in dependencies');
    ok((grep { $_ eq 'Mojolicious::Plugin::Fondation::OpenAPI' } @names), 'OpenAPI in dependencies');
    ok((grep { $_ eq 'Mojolicious::Plugin::Fondation::I18N' } @names), 'I18N in dependencies');
};

done_testing;
