#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use StarterTestHelper qw(build_app);

my ($app, $t, $tempdir) = build_app();

# ─── Tables created ──────────────────────────────────────────────────────────

subtest 'tables created' => sub {
    my $c      = $app->build_controller;
    my $schema = $c->schema;
    my @sources = sort $schema->sources;
    ok((grep { $_ eq 'users' }      @sources), 'users table exists');
    ok((grep { $_ eq 'groups' }     @sources), 'groups table exists');
    ok((grep { $_ eq 'user_group' } @sources), 'user_group table exists');
    is(scalar @sources, 3, 'exactly 3 tables');
};

# ─── Fixtures: users ─────────────────────────────────────────────────────────

subtest 'fixtures: users' => sub {
    my $c      = $app->build_controller;
    my $schema = $c->schema;

    my $user = $schema->await($c->model('user')->find(1));
    ok($user, 'admin user (id=1) exists');
    is($user->username, 'admin', 'admin username is admin');
    is($user->active,   1,       'admin is active');
    is($user->email,    'admin@example.com', 'admin email');
};

# ─── Fixtures: groups ────────────────────────────────────────────────────────

subtest 'fixtures: groups' => sub {
    my $c      = $app->build_controller;
    my $schema = $c->schema;

    my $admin_group = $schema->await($c->model('group')->find(1));
    ok($admin_group, 'admin group (id=1) exists');
    is($admin_group->name,   'admin', 'group 1 name is admin');
    is($admin_group->active, 1,       'group 1 is active');

    my $user_group = $schema->await($c->model('group')->find(2));
    ok($user_group, 'user group (id=2) exists');
    is($user_group->name,   'user', 'group 2 name is user');
    is($user_group->active, 1,      'group 2 is active');
};

# ─── Fixtures: user_group ────────────────────────────────────────────────────

subtest 'fixtures: user_group' => sub {
    my $c      = $app->build_controller;
    my $schema = $c->schema;

    my $rs    = $c->model('user_group');
    my $links = $schema->await($rs->search({})->all);
    is(scalar @$links, 1, 'exactly 1 user_group link');

    my $link = $links->[0];
    is($link->user_id,  1, 'user_id is 1 (admin)');
    is($link->group_id, 1, 'group_id is 1 (admin group)');
};

# ─── schema_drift helper ─────────────────────────────────────────────────────

subtest 'schema_drift' => sub {
    my $c     = $app->build_controller;
    my $drift = $c->schema_drift;
    isa_ok($drift, 'HASH', 'schema_drift returns hashref');
    ok(!$drift->{has_drift}, 'no schema drift after fresh install');
};

done_testing;
