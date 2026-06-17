package StarterTestHelper;

# ABSTRACT: Build a full Starter app with all plugins loaded and DB deployed

use strict;
use warnings;
use File::Temp 'tempdir';
use Test::Mojo;
use Mojo::File 'path';
use Mojolicious::Plugin::Fondation::TestHelper qw(create_test_app);

our @EXPORT_OK = qw(build_app);
use base 'Exporter';

sub build_app {
    my $tempdir = tempdir(CLEANUP => 1);

    my $app = create_test_app($tempdir);

    # Create lib/MySchema.pm before loading plugins so that Action::DBIx
    # can register Result sources on it during startup.
    my $lib_dir = $app->home->child('lib');
    $lib_dir->make_path;
    path($lib_dir, 'MySchema.pm')->spurt(<<'SCHEMA');
package MySchema;

# BOOTSTRAPPED BY Fondation::MigrationDBIx -- do not edit this marker.

use base 'DBIx::Class::Schema';

our $VERSION = '1';

__PACKAGE__->load_namespaces;
1;
SCHEMA
    unshift @INC, $lib_dir->to_string;

    $app->plugin('Fondation' => {
        dependencies => [
            { 'Fondation::Model::DBIx::Async' => {
                backends => [
                    main => {
                        dsn          => "dbi:SQLite:dbname=$tempdir/app.db",
                        schema_class => 'MySchema',
                        workers      => 1,
                    },
                ],
            }},
            'Fondation::MigrationDBIx',
            'Fondation::OpenAPI',
            'Fondation::Layout::Bootstrap',
            'Fondation::User::UI::Bootstrap',
            'Fondation::Auth',
            'Fondation::Asset',
            'Fondation::I18N',
            'Fondation::User',
            'Fondation::Group',
            'Fondation::Devel',
        ],
    });

    $app->commands->run('fondation', 'init');

    my $t = Test::Mojo->new($app);

    return ($app, $t, $tempdir);
}

1;
