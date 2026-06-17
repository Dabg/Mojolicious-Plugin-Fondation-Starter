#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use Mojo::File 'path';
use JSON::MaybeXS qw(decode_json);
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use StarterTestHelper qw(build_app);

my ($app, $t, $tempdir) = build_app();

my $spec_file    = $app->home->child('share',  'openapi.json');
my $validators_file = $app->home->child('public', 'js', 'validators.js');
ok(-f $spec_file,        'share/openapi.json exists');
ok(-f $validators_file,  'public/js/validators.js exists');

my $spec = decode_json($spec_file->slurp);

# ─── OpenAPI version ─────────────────────────────────────────────────────────

subtest 'version' => sub {
    is($spec->{openapi}, '3.0.3', 'OpenAPI version 3.0.3');
    ok($spec->{info}{title},     'has title');
};

# ─── User paths ──────────────────────────────────────────────────────────────

subtest 'User paths' => sub {
    ok(exists $spec->{paths}{'/user'},        'GET/POST /user');
    ok(exists $spec->{paths}{'/user/{id}'},   'GET/PUT/DELETE /user/{id}');
};

# ─── Group paths ─────────────────────────────────────────────────────────────

subtest 'Group paths' => sub {
    ok(exists $spec->{paths}{'/group'},        'GET/POST /group');
    ok(exists $spec->{paths}{'/group/{id}'},   'GET/PUT/DELETE /group/{id}');
};

# ─── User operations ─────────────────────────────────────────────────────────

subtest 'User operations' => sub {
    my $user = $spec->{paths}{'/user'};
    is($user->{get}{operationId},  'list_user',   'GET list_user');
    is($user->{post}{operationId}, 'create_user',  'POST create_user');

    my $user_id = $spec->{paths}{'/user/{id}'};
    is($user_id->{get}{operationId},    'read_user',   'GET read_user');
    is($user_id->{put}{operationId},    'update_user', 'PUT update_user');
    is($user_id->{patch}{operationId},  'patch_user',  'PATCH patch_user');
    is($user_id->{delete}{operationId}, 'delete_user', 'DELETE delete_user');
};

# ─── Group operations ────────────────────────────────────────────────────────

subtest 'Group operations' => sub {
    my $group = $spec->{paths}{'/group'};
    is($group->{get}{operationId},  'list_group',   'GET list_group');
    is($group->{post}{operationId}, 'create_group',  'POST create_group');

    my $group_id = $spec->{paths}{'/group/{id}'};
    is($group_id->{get}{operationId},    'read_group',   'GET read_group');
    is($group_id->{put}{operationId},    'update_group', 'PUT update_group');
    is($group_id->{patch}{operationId},  'patch_group',  'PATCH patch_group');
    is($group_id->{delete}{operationId}, 'delete_group', 'DELETE delete_group');
};

# ─── user_group excluded from spec ───────────────────────────────────────────

subtest 'user_group excluded' => sub {
    ok(!exists $spec->{paths}{'/user_group'},
        'user_group not exposed in OpenAPI spec');
};

# ─── Schemas ─────────────────────────────────────────────────────────────────

subtest 'schemas' => sub {
    ok(exists $spec->{components}{schemas}{User},  'User schema defined');
    ok(exists $spec->{components}{schemas}{Group}, 'Group schema defined');
};

done_testing;
