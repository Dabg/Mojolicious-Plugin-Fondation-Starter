#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use StarterTestHelper qw(build_app);
use Mojolicious::Plugin::Fondation::User::Schema::Result::User;

my ($app, $t, $tempdir) = build_app();

my $c      = $app->build_controller;
my $schema = $c->schema;
my $rs     = $c->model('user');

# ─── Create ──────────────────────────────────────────────────────────────────

subtest 'create' => sub {
    my $user = $schema->await($rs->create({
        username => 'bob',
        email    => 'bob@example.com',
        password => 'secret123',
    }));
    ok($user->id, 'user created with id');
    is($user->username, 'bob', 'username set');
    is($user->email,    'bob@example.com', 'email set');
    is($user->active,   1, 'active defaults to 1');
};

# ─── Password hashing ────────────────────────────────────────────────────────

subtest 'password hashing' => sub {
    my $user = $schema->await($rs->find({ username => 'bob' }));
    ok($user, 'bob found');
    isnt($user->password, 'secret123', 'password is hashed');
    ok($user->check_password('secret123'), 'check_password returns true');
    ok(!$user->check_password('wrong'),    'check_password rejects wrong');
};

# ─── Read (find) ─────────────────────────────────────────────────────────────

subtest 'read' => sub {
    my $user = $schema->await($rs->find({ username => 'bob' }));
    ok($user, 'find by username works');
    is($user->email, 'bob@example.com', 'email matches');

    my $by_id = $schema->await($rs->find($user->id));
    ok($by_id, 'find by id works');
};

# ─── Search ──────────────────────────────────────────────────────────────────

subtest 'search' => sub {
    my $results = $schema->await($rs->search({ active => 1 })->all);
    ok(scalar @$results >= 2, 'found admin + bob');
};

# ─── Update ──────────────────────────────────────────────────────────────────

subtest 'update' => sub {
    my $user = $schema->await($rs->find({ username => 'bob' }));
    $schema->await($user->update({ email => 'bob-new@example.com' }));
    my $updated = $schema->await($rs->find($user->id));
    is($updated->email, 'bob-new@example.com', 'email updated');
};

# ─── Delete ──────────────────────────────────────────────────────────────────

subtest 'delete' => sub {
    my $user = $schema->await($rs->find({ username => 'bob' }));
    $schema->await($user->delete);
    my $gone = $schema->await($rs->find($user->id));
    ok(!$gone, 'user deleted');
};

done_testing;
