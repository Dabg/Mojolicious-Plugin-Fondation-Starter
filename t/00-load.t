#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use_ok('Mojolicious::Plugin::Fondation::Starter');
can_ok('Mojolicious::Plugin::Fondation::Starter', 'VERSION');

done_testing;
