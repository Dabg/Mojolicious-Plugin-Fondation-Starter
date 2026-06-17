#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use StarterTestHelper qw(build_app);

my ($app, $t, $tempdir) = build_app();

my $c      = $app->build_controller;
my $schema = $c->schema;
my $g_rs   = $c->model('group');
my $ug_rs  = $c->model('user_group');

# ─── Create ──────────────────────────────────────────────────────────────────

subtest 'create' => sub {
    my $group = $schema->await($g_rs->create({
        name   => 'editors',
        active => 1,
    }));
    ok($group->id, 'group created with id');
    is($group->name,   'editors', 'name set');
    is($group->active, 1,         'active set');
};

# ─── Read ────────────────────────────────────────────────────────────────────

subtest 'read' => sub {
    my $group = $schema->await($g_rs->find({ name => 'editors' }));
    ok($group, 'find by name works');
    is($group->active, 1, 'active matches');

    my $by_id = $schema->await($g_rs->find($group->id));
    ok($by_id, 'find by id works');
    is($by_id->name, 'editors', 'name by id matches');
};

# ─── Search ──────────────────────────────────────────────────────────────────

subtest 'search' => sub {
    my $results = $schema->await($g_rs->search({ active => 1 })->all);
    ok(scalar @$results >= 3, 'found admin + user + editors');
};

# ─── Update ──────────────────────────────────────────────────────────────────

subtest 'update' => sub {
    my $group = $schema->await($g_rs->find({ name => 'editors' }));
    $schema->await($group->update({ name => 'contributors' }));
    my $updated = $schema->await($g_rs->find($group->id));
    is($updated->name, 'contributors', 'name updated');
};

# ─── Add user to group ───────────────────────────────────────────────────────

subtest 'add user to group' => sub {
    my $group = $schema->await($g_rs->find({ name => 'contributors' }));
    my $user  = $schema->await($c->model('user')->find(1));  # admin

    my $link = $schema->await($ug_rs->create({
        user_id  => $user->id,
        group_id => $group->id,
    }));
    ok($link->id, 'user_group link created');
    is($link->user_id,  $user->id,  'user_id correct');
    is($link->group_id, $group->id, 'group_id correct');
};

# ─── Remove user from group ─────────────────────────────────────────────────

subtest 'remove user from group' => sub {
    my $group = $schema->await($g_rs->find({ name => 'contributors' }));
    my $links = $schema->await($ug_rs->search({ group_id => $group->id })->all);
    $schema->await($_->delete) for @$links;

    my $remaining = $schema->await($ug_rs->search({ group_id => $group->id })->all);
    is(scalar @$remaining, 0, 'user removed from group');
};

# ─── Delete group ────────────────────────────────────────────────────────────

subtest 'delete group' => sub {
    my $group = $schema->await($g_rs->find({ name => 'contributors' }));
    $schema->await($group->delete);
    my $gone = $schema->await($g_rs->find($group->id));
    ok(!$gone, 'group deleted');
};

done_testing;
