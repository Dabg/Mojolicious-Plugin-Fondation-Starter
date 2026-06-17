#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin;
use Mojo::File 'path';
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";
use StarterTestHelper qw(build_app);

my ($app, $t, $tempdir) = build_app();

# ─── assetpack.def exists ────────────────────────────────────────────────────

my $def_file = $app->home->child('assets', 'assetpack.def');
ok(-f $def_file, 'assets/assetpack.def exists');

my $content = $def_file->slurp;

# ─── Contains expected CSS libraries ─────────────────────────────────────────

subtest 'css libraries' => sub {
    like($content, qr/swagger-ui\.css/,    'swagger-ui.css');
    like($content, qr/bootstrap\.min\.css/, 'bootstrap.min.css');
};

# ─── Contains expected JS libraries ──────────────────────────────────────────

subtest 'js libraries' => sub {
    like($content, qr{js/validators\.js},    'js/validators.js');
    like($content, qr{js/DatatableUser\.js}, 'js/DatatableUser.js');
};

# ─── Asset cache populated ───────────────────────────────────────────────────

subtest 'asset cache' => sub {
    my $cache = $app->home->child('assets', 'cache');
    ok(-d $cache, 'assets/cache exists');
    my @files = @{ $cache->list_tree // [] };
    ok(scalar @files > 0, 'cache has files');
};

done_testing;
