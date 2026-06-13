package Mojolicious::Plugin::Fondation::Starter;

# ABSTRACT: Curated starter stack for Fondation -- sensible defaults, nothing more

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
-- all orchestrated by the C<fondation init|upgrade|refresh> commands provided
by Fondation core.

But this list is not set in stone. The core principle of Fondation is
composition: each plugin is a self-contained brick. You can freely:

=over

=item * Add your own plugins to the dependencies list

=item * Override any plugin config directly in C<myapp.pl>. For example,
to use PostgreSQL instead of SQLite: (see CONFIGURATION)

=item * Skip Starter entirely and declare your own subset of plugins

=back

Because Fondation merges arrays by concatenation, Starter's plugins are always
present. To use a different set, declare them manually instead of including
C<Fondation::Starter>. See L</CONFIGURATION> for details.

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

Config passed directly in C<myapp.pl> takes priority -- it overrides the
plugin defaults. No need for C<myapp.conf> just for that.

Fondation::Starter is a worked example of what you can build with a handful
of standard plugins. It's not a straitjacket -- take what you need, remove
the rest, add your own.

B<This plugin is experimental.> It's a step-by-step exploration of how
Fondation plugins compose together. Things may change as the ecosystem evolves.

=head1 DEFAULT CONFIGURATION

The following dependencies are loaded automatically:

=over

=item * L<Mojolicious::Plugin::Fondation::Model::DBIx::Async> -- async DBIx::Class layer (defaults to SQLite, supports any DBI backend)

=item * L<Mojolicious::Plugin::Fondation::MigrationDBIx> -- database migration management

=item * L<Mojolicious::Plugin::Fondation::User> -- user management

=item * L<Mojolicious::Plugin::Fondation::Layout::Bootstrap> -- Bootstrap layout

=item * L<Mojolicious::Plugin::Fondation::User::UI::Bootstrap> -- Bootstrap user UI

=item * L<Mojolicious::Plugin::Fondation::Asset> -- asset pipeline

=item * L<Mojolicious::Plugin::Fondation::OpenAPI> -- OpenAPI spec generation

=item * L<Mojolicious::Plugin::Fondation::I18N> -- internationalization

=back

=head1 ORCHESTRATION

Fondation core provides three commands that iterate over all loaded plugins:

  myapp.pl fondation init         # First-time setup
  myapp.pl fondation upgrade      # After adding/removing/updating a plugin
  myapp.pl fondation refresh      # Full reset (destroys data)

Each plugin declares what it contributes via C<fondation_meta -> defaults>.
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

Because Fondation merges arrays by concatenation, you can B<add> plugins to
Starter's list but you cannot remove them. To add extra plugins:

  plugin 'Fondation' => {
      dependencies => [
          { 'Fondation::Starter' => {
              dependencies => ['MyPlugin'],   # added to the default list
          }},
      ],
  };

Or in a separate C<myapp.conf> file (Mojolicious auto-loads it if present):

  # myapp.conf
  {
      'Fondation::Starter' => {
          dependencies => ['MyPlugin'],
      },
  }

Both are equivalent -- config passed directly in C<myapp.pl> takes priority.

If you need a different subset of plugins, do not use C<Fondation::Starter>.
Declare your own list instead:

  plugin 'Fondation' => {
      dependencies => [
          'Fondation::User',
          'Mojolicious::Plugin::Fondation::Asset',
          'MyPlugin',
      ],
  };

Starter is a convenience, not a straitjacket.

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

                # Before Auth to overwrite template login.
                'Mojolicious::Plugin::Fondation::Layout::Bootstrap',
                'Mojolicious::Plugin::Fondation::User::UI::Bootstrap',

                'Fondation::Auth',
                'Mojolicious::Plugin::Fondation::Asset',
                'Mojolicious::Plugin::Fondation::I18N',

                'Fondation::User',
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
