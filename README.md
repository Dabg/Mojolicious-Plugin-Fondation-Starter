# NAME

Mojolicious::Plugin::Fondation::Starter - Curated starter stack for Fondation -- sensible defaults, nothing more

# VERSION

version 0.01

# SYNOPSIS

    # myapp.pl
    #!/usr/bin/env perl
    use Mojolicious::Lite;
    use lib 'lib';
    plugin 'Fondation' => {
        dependencies => ['Fondation::Starter'],
    };
    app->start;

# DESCRIPTION

Fondation::Starter is not a monolithic framework. It's just another Fondation
plugin that declares a convenient set of dependencies by default. With a single
`dependencies` entry, you get a database, migrations, user management, a
Bootstrap UI, OpenAPI spec generation, asset pipeline, and internationalization
\-- all orchestrated by the `fondation init|upgrade|refresh` commands provided
by Fondation core.

But this list is not set in stone. The core principle of Fondation is
composition: each plugin is a self-contained brick. You can freely:

- Add your own plugins to the dependencies list
- Override any plugin config directly in `myapp.pl`. For example,
to use PostgreSQL instead of SQLite: (see CONFIGURATION)
- Skip Starter entirely and declare your own subset of plugins

Because Fondation merges arrays by concatenation, Starter's plugins are always
present. To use a different set, declare them manually instead of including
`Fondation::Starter`. See ["CONFIGURATION"](#configuration) for details.

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

Config passed directly in `myapp.pl` takes priority -- it overrides the
plugin defaults. No need for `myapp.conf` just for that.

Fondation::Starter is a worked example of what you can build with a handful
of standard plugins. It's not a straitjacket -- take what you need, remove
the rest, add your own.

**This plugin is experimental.** It's a step-by-step exploration of how
Fondation plugins compose together. Things may change as the ecosystem evolves.

# DEFAULT CONFIGURATION

The following dependencies are loaded automatically:

- [Mojolicious::Plugin::Fondation::Model::DBIx::Async](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AModel%3A%3ADBIx%3A%3AAsync) -- async DBIx::Class layer (defaults to SQLite, supports any DBI backend)
- [Mojolicious::Plugin::Fondation::MigrationDBIx](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AMigrationDBIx) -- database migration management
- [Mojolicious::Plugin::Fondation::User](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AUser) -- user management
- [Mojolicious::Plugin::Fondation::Layout::Bootstrap](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3ALayout%3A%3ABootstrap) -- Bootstrap layout
- [Mojolicious::Plugin::Fondation::User::UI::Bootstrap](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AUser%3A%3AUI%3A%3ABootstrap) -- Bootstrap user UI
- [Mojolicious::Plugin::Fondation::Asset](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AAsset) -- asset pipeline
- [Mojolicious::Plugin::Fondation::OpenAPI](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AOpenAPI) -- OpenAPI spec generation
- [Mojolicious::Plugin::Fondation::I18N](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AI18N) -- internationalization

# ORCHESTRATION

Fondation core provides three commands that iterate over all loaded plugins:

    myapp.pl fondation init         # First-time setup
    myapp.pl fondation upgrade      # After adding/removing/updating a plugin
    myapp.pl fondation refresh      # Full reset (destroys data)

Each plugin declares what it contributes via `fondation_meta -` defaults>.
See [Mojolicious::Plugin::Fondation::Command::fondation](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3ACommand%3A%3Afondation) for the full
plugin contract.

# TYPICAL WORKFLOW

    # New application
    myapp.pl db bootstrap-schema
    myapp.pl fondation init

    # Start the application
    myapp.pl daemon

    # After adding/removing/updating a plugin
    myapp.pl fondation upgrade

    # Full reset (destroys data)
    myapp.pl fondation refresh

# CONFIGURATION

Because Fondation merges arrays by concatenation, you can **add** plugins to
Starter's list but you cannot remove them. To add extra plugins:

    plugin 'Fondation' => {
        dependencies => [
            { 'Fondation::Starter' => {
                dependencies => ['MyPlugin'],   # added to the default list
            }},
        ],
    };

Or in a separate `myapp.conf` file (Mojolicious auto-loads it if present):

    # myapp.conf
    {
        'Fondation::Starter' => {
            dependencies => ['MyPlugin'],
        },
    }

Both are equivalent -- config passed directly in `myapp.pl` takes priority.

If you need a different subset of plugins, do not use `Fondation::Starter`.
Declare your own list instead:

    plugin 'Fondation' => {
        dependencies => [
            'Fondation::User',
            'Mojolicious::Plugin::Fondation::Asset',
            'MyPlugin',
        ],
    };

Starter is a convenience, not a straitjacket.

# AUTHOR

Daniel Brosseau <dab@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2026 by Daniel Brosseau.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
