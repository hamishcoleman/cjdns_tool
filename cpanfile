
# This file is only used for the requirements in the CI environment.
# Rember to always update the makefile if new dependancies are added here
#
# TODO:
# - reduce insanity and just ditch this and use debian packages
#

on test => sub {
    requires 'Test::More';
    requires 'Test::Exception';
    requires 'Devel::Cover';
    requires 'MIME::Base64';
};

