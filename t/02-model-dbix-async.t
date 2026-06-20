#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use StarterTestHelper qw(build_app);

my ($app, $t, $tempdir) = build_app();

# ─── schema_class helper ──────────────────────────────────────────────────────

subtest 'schema_class' => sub {
    my $c = $app->build_controller;
    is($c->schema_class, 'MySchema', 'schema_class returns MySchema');
};

# ─── backend_config helper ────────────────────────────────────────────────────

subtest 'backend_config' => sub {
    my $c   = $app->build_controller;
    my $cfg = $c->backend_config;
    isa_ok($cfg, 'HASH', 'backend_config returns hashref');
    like($cfg->{dsn}, qr/SQLite/, 'dsn is SQLite');
    is($cfg->{schema_class}, 'MySchema', 'schema_class in config');
    is($cfg->{workers}, 1, 'workers is 1');
};

# ─── default_backend_name helper ──────────────────────────────────────────────

subtest 'default_backend_name' => sub {
    my $c = $app->build_controller;
    is($c->default_backend_name, 'main', 'default_backend_name is main');
};

# ─── schema helper and registered sources ─────────────────────────────────────

subtest 'schema and sources' => sub {
    my $c      = $app->build_controller;
    my $schema = $c->schema;
    isa_ok($schema, 'DBIx::Class::Async::Schema', 'schema returns Async::Schema');

    my @sources = sort $schema->sources;
    ok((grep { $_ eq 'User' }      @sources), 'User source registered');
    ok((grep { $_ eq 'Group' }     @sources), 'Group source registered');
    ok((grep { $_ eq 'UserGroup' } @sources), 'UserGroup source registered');
};

# ─── model helper ─────────────────────────────────────────────────────────────

subtest 'model helper' => sub {
    my $c = $app->build_controller;

    my $user_rs = $c->model('user');
    isa_ok($user_rs, 'DBIx::Class::Async::ResultSet', 'model(user) returns ResultSet');

    my $group_rs = $c->model('group');
    isa_ok($group_rs, 'DBIx::Class::Async::ResultSet', 'model(group) returns ResultSet');
};

# ─── model_config helper ──────────────────────────────────────────────────────

subtest 'model_config' => sub {
    my $c = $app->build_controller;

    my $ucfg = $c->model_config('user');
    is($ucfg->{source}, 'User', 'user model source is User');

    my $gcfg = $c->model_config('group');
    is($gcfg->{source}, 'Group', 'group model source is Group');
};

# ─── model_list helper ────────────────────────────────────────────────────────

subtest 'model_list' => sub {
    my $c      = $app->build_controller;
    my @models = @{$c->model_list};
    ok((grep { $_ eq 'user' }       @models), 'user in model_list');
    ok((grep { $_ eq 'group' }      @models), 'group in model_list');
    ok((grep { $_ eq 'user_group' } @models), 'user_group in model_list');
};

done_testing;
