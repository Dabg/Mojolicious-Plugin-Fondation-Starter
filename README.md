# NAME

Mojolicious::Plugin::Fondation::Starter - Curated starter stack for Fondation — sensible defaults, nothing more

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
— all orchestrated by the `fondation init|upgrade|refresh` commands provided
by Fondation core.

But this list is not set in stone. The core principle of Fondation is
composition: each plugin is a self-contained brick. You can freely:

- Remove `Fondation::I18N` if you don't need translation
- Replace `Layout::Bootstrap` with your own layout plugin
- Add your own plugins to the dependencies list
- Override any plugin config directly in `myapp.pl`. For example,
to use PostgreSQL instead of SQLite:

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

Config passed directly in `myapp.pl` takes priority — it overrides the
plugin defaults. No need for `myapp.conf` just for that.

Fondation::Starter is a worked example of what you can build with a handful
of standard plugins. It's not a straitjacket — take what you need, remove
the rest, add your own.

**This plugin is experimental.** It's a step-by-step exploration of how
Fondation plugins compose together. Things may change as the ecosystem evolves.

# NAME

Mojolicious::Plugin::Fondation::Starter - Curated starter stack of Fondation plugins

# DEFAULT CONFIGURATION

The following dependencies are loaded automatically:

- [Mojolicious::Plugin::Fondation::Model::DBIx::Async](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AModel%3A%3ADBIx%3A%3AAsync) — SQLite backend with `MySchema`
- [Mojolicious::Plugin::Fondation::MigrationDBIx](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AMigrationDBIx) — database migration management
- [Mojolicious::Plugin::Fondation::User](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AUser) — user management
- [Mojolicious::Plugin::Fondation::Layout::Bootstrap](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3ALayout%3A%3ABootstrap) — Bootstrap layout
- [Mojolicious::Plugin::Fondation::User::UI::Bootstrap](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AUser%3A%3AUI%3A%3ABootstrap) — Bootstrap user UI
- [Mojolicious::Plugin::Fondation::Asset](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AAsset) — asset pipeline
- [Mojolicious::Plugin::Fondation::OpenAPI](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AOpenAPI) — OpenAPI spec generation
- [Mojolicious::Plugin::Fondation::I18N](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AFondation%3A%3AI18N) — internationalization

To override a dependency, declare it before `Fondation::Starter` in the
`dependencies` array. The config cascade (direct > app config > defaults)
resolves duplicates, so your version takes priority.

-# ORCHESTRATION

Fondation core provides three commands that iterate over all loaded plugins:

    myapp.pl fondation init         # First-time setup
    myapp.pl fondation upgrade      # After adding/removing/updating a plugin
    myapp.pl fondation refresh      # Full reset (destroys data)

Each plugin declares what it contributes via `fondation_meta → defaults`.
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

Config can be set directly in `myapp.pl`:

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

Or in a separate `myapp.conf` file (Mojolicious auto-loads it if present):

    # myapp.conf
    {
        'Fondation::Starter' => {
            dependencies => ['Fondation::User'],
        },
    }

Both are equivalent — config passed directly in `myapp.pl` takes priority.

# AUTHOR

Daniel Brosseau <dab@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2026 by Daniel Brosseau.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
