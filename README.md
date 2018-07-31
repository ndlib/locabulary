# Locabulary

[![Build Status](https://travis-ci.org/ndlib/locabulary.png?branch=master)](https://travis-ci.org/ndlib/locabulary)
[![Code Climate](https://codeclimate.com/github/ndlib/locabulary.png)](https://codeclimate.com/github/ndlib/locabulary)
[![Test Coverage](https://codeclimate.com/github/ndlib/locabulary/badges/coverage.svg)](https://codeclimate.com/github/ndlib/locabulary)
[![Dependency Status](https://gemnasium.com/ndlib/locabulary.svg)](https://gemnasium.com/ndlib/locabulary)
[![Documentation Status](http://inch-ci.org/github/ndlib/locabulary.svg?branch=master)](http://inch-ci.org/github/ndlib/locabulary)
[![APACHE 2 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

An extraction of limited localized vocabulary for Sipity and CurateND.
This controlled vocabulary has a limited shelf-life as we explore other more
robust options.

## Getting Started

See the [Locublary module in lib/locabulary](/lib/locabulary.rb) for the public methods of this gem.

## Testing
Install the gems via `BUNDLE_GEMFILE=gemfiles/activesupport4.gemfile bundle install`

The full test suite is run via `bundle exec rake`.

If you are interested in running each file in isolation - a good thing for unit tests - use `./bin/rspec_isolated`.

## Updating Data Files

The "administrative_units" data is maintained in a Google Spreadsheet. To synchronize the JSON data:

1. Ensure that you have a copy of the `config/client_secret.yml` from the staging secrets
2. Make sure you have a clean working tree (eg. `git status` shows no changes)
3. Run `bundle exec ./script/update_data_files.sh` script following its instructions
4. Review changes to the `data/administrative_units.json` file (eg. `git diff`)
5. Commit changes

Once committed and pushed upstream, to see the changes will require a deploy of the applications.
