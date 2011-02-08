#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'cpanvote';
all_from 'lib/cpanvote.pm';

requires 'Catalyst::Runtime' => '5.80018';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'Catalyst::Authentication::Credential::HTTP';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::View::Mason';
requires 'Catalyst::Plugin::Session::PerUser';
requires 'Catalyst::Plugin::Session::Store::DBIC';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Cache::Memory';
requires 'Catalyst::Controller::REST';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Cache';
requires 'Config::General';
requires 'Catalyst::Authentication::Credential::Twitter';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
