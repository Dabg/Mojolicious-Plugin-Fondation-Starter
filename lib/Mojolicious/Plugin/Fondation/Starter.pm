package Mojolicious::Plugin::Fondation::Starter;

# ABSTRACT: Curated starter stack for Fondation — sensible defaults, nothing more

use Mojo::Base 'Mojolicious::Plugin', -signatures;

our $VERSION = '0.01';

=head1 NAME

Mojolicious::Plugin::Fondation::Starter - Curated starter stack of Fondation plugins

=head1 SYNOPSIS

  # myapp.pl
  #!/usr/bin/env perl
  use Mojolicious::Lite;
  use lib 'lib';
  plugin 'Fondation' => {
      dependencies => ['Fondation::Starter'],
  };
  app->start;

=head1 DESCRIPTION

Fondation::Starter is not a monolithic framework. It's just another Fondation
plugin that declares a convenient set of dependencies by default. With a single
C<dependencies> entry, you get a database, migrations, user management, a
Bootstrap UI, OpenAPI spec generation, asset pipeline, and internationalization
— all orchestrated by the C<fondation init|upgrade|refresh> commands provided
by Fondation core.

But this list is not set in stone. The core principle of Fondation is
composition: each plugin is a self-contained brick. You can freely:

=over

=item * Remove C<Fondation::I18N> if you don't need translation

=item * Replace C<Layout::Bootstrap> with your own layout plugin

=item * Add your own plugins to the dependencies list

=item * Override any plugin config directly in C<myapp.pl>. For example,
to use PostgreSQL instead of SQLite:

=back

  plugin 'Fondation' => {
      dependencies => [
          { 'Fondation::Model::DBIx::Async' => {
              backends => [
                  main => {
                      dsn          => 'dbi:Pg:dbname=myapp',
                      schema_class => 'MySchema',
                      user         => 'myuser',
                      pass         => 'mypass',
                  },
              ],
          }},
          'Fondation::Starter',   # everything else is still included
      ],
  };

Config passed directly in C<myapp.pl> takes priority — it overrides the
plugin defaults. No need for C<myapp.conf> just for that.

Fondation::Starter is a worked example of what you can build with a handful
of standard plugins. It's not a straitjacket — take what you need, remove
the rest, add your own.

B<This plugin is experimental.> It's a step-by-step exploration of how
Fondation plugins compose together. Things may change as the ecosystem evolves.

=head1 DEFAULT CONFIGURATION

The following dependencies are loaded automatically:

=over

=item * L<Mojolicious::Plugin::Fondation::Model::DBIx::Async> — SQLite backend with C<MySchema>

=item * L<Mojolicious::Plugin::Fondation::MigrationDBIx> — database migration management

=item * L<Mojolicious::Plugin::Fondation::User> — user management

=item * L<Mojolicious::Plugin::Fondation::Layout::Bootstrap> — Bootstrap layout

=item * L<Mojolicious::Plugin::Fondation::User::UI::Bootstrap> — Bootstrap user UI

=item * L<Mojolicious::Plugin::Fondation::Asset> — asset pipeline

=item * L<Mojolicious::Plugin::Fondation::OpenAPI> — OpenAPI spec generation

=item * L<Mojolicious::Plugin::Fondation::I18N> — internationalization

=back

To override a dependency, declare it before C<Fondation::Starter> in the
C<dependencies> array. The config cascade (direct > app config > defaults)
resolves duplicates, so your version takes priority.

=head1 ORCHESTRATION

Fondation core provides three commands that iterate over all loaded plugins:

  myapp.pl fondation init         # First-time setup
  myapp.pl fondation upgrade      # After adding/removing/updating a plugin
  myapp.pl fondation refresh      # Full reset (destroys data)

Each plugin declares what it contributes via C<fondation_meta → defaults>.
See L<Mojolicious::Plugin::Fondation::Command::fondation> for the full
plugin contract.

=head1 TYPICAL WORKFLOW

  # New application
  myapp.pl db bootstrap-schema
  myapp.pl fondation init

  # Start the application
  myapp.pl daemon

  # After adding/removing/updating a plugin
  myapp.pl fondation upgrade

  # Full reset (destroys data)
  myapp.pl fondation refresh

=head1 CONFIGURATION

Config can be set directly in C<myapp.pl>:

  plugin 'Fondation' => {
      dependencies => [
          { 'Fondation::Starter' => {
              dependencies => [
                  # Override the entire dependency list
                  'Fondation::User',
                  'Mojolicious::Plugin::Fondation::Asset',
              ],
          }},
      ],
  };

Or in a separate C<myapp.conf> file (Mojolicious auto-loads it if present):

  # myapp.conf
  {
      'Fondation::Starter' => {
          dependencies => ['Fondation::User'],
      },
  }

Both are equivalent — config passed directly in C<myapp.pl> takes priority.

=cut

sub fondation_meta {
    return {
        defaults => {
            dependencies => [
                { 'Fondation::Model::DBIx::Async' => {
                    backends => [
                        main => {
                            dsn          => 'dbi:SQLite:dbname=data/app.db',
                            schema_class => 'MySchema',
                            workers      => 2,
                        },
                    ],
                }},
                'Fondation::MigrationDBIx',
                'Mojolicious::Plugin::Fondation::OpenAPI',
                'Mojolicious::Plugin::Fondation::Asset',
                'Mojolicious::Plugin::Fondation::I18N',

                'Fondation::User',
                'Mojolicious::Plugin::Fondation::Layout::Bootstrap',
                'Mojolicious::Plugin::Fondation::User::UI::Bootstrap',
                ],
        },
    };
}

sub register ($self, $app, $conf = {}) {
    return $self;
}

sub fondation_finalyze ($self, $app, $long_name) {
    $self->log->debug("$long_name ready");
}

1;
