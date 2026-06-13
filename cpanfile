# CPAN dependencies for Mojolicious-Plugin-Fondation-Starter
# This file is used by cpanminus (cpanm) and Carton

# Minimum Perl version required (for Mojolicious signatures feature)
requires 'perl' => '5.026';

# Runtime dependencies
requires 'Mojolicious'                       => '9.46';
requires 'Mojolicious::Plugin::Fondation'    => '0.01';

# All plugins bundled by Fondation::Starter defaults
requires 'Mojolicious::Plugin::Fondation::Model::DBIx::Async' => '0.01';
requires 'Mojolicious::Plugin::Fondation::MigrationDBIx'      => '0.01';
requires 'Mojolicious::Plugin::Fondation::User'               => '0.01';
requires 'Mojolicious::Plugin::Fondation::Layout::Bootstrap'  => '0.01';
requires 'Mojolicious::Plugin::Fondation::User::UI::Bootstrap' => '0.01';
requires 'Mojolicious::Plugin::Fondation::Asset'              => '0.01';
requires 'Mojolicious::Plugin::Fondation::OpenAPI'            => '0.01';
requires 'Mojolicious::Plugin::Fondation::I18N'               => '0.01';

# Testing dependencies
on test => sub {
    requires 'Test::More' => '1.00';
    requires 'Mojolicious::Plugin::Fondation::TestHelper' => '0';
};

# Development dependencies (for author)
on develop => sub {
    recommends 'Perl::Critic' => '1.00';
    recommends 'Perl::Tidy'   => '20200000';
    recommends 'Pod::Checker' => '1.00';
};
