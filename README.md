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

At its core Locabulary provides a set of public methods that helps with building a list or hierarchy tree of controlled vocabularies.

The module methods marked `@api public` in the [Locabulary top-level module](/lib/locabulary.rb) are the public facing methods that both Sipity and CurateND utilize.  They should not use any other methods of Locabulary.

As such, the implementation details of Locabulary are opaque to downstream dependencies.

Peeling the details back a bit, Locabulary provides several controlled vocabularies. You can find them in the [./data](/data/) directory.  By convention, the data file is the predicate_name of the term (e.g. the `predicate_name: "copyright"` will use the ./data/copyright.json data).

Everything else is about mapping and querying the JSON data.

## Testing

Install the gems via `BUNDLE_GEMFILE=gemfiles/activesupport4.gemfile bundle install`

The full test suite is run via `bundle exec rake`.

If you are interested in running each file in isolation - a good thing for unit tests - use `./bin/rspec_isolated`.

### Testing/Using Different Gemfiles

If you want to run your tests via a different gemfile, see the following:

```console
$ BUNDLE_GEMFILE=gemfiles/activesupport4.gemfile bundle update
$ BUNDLE_GEMFILE=gemfiles/activesupport4.gemfile bundle install
$ BUNDLE_GEMFILE=gemfiles/activesupport4.gemfile bundle exec rspec
```

See the [Bundler `bundle config` documentation](https://bundler.io/v1.16/bundle_config.html) for further information.

## Updating Data Files

The "administrative_units" data is maintained in a Google Spreadsheet. To synchronize the JSON data:

1. Ensure that you have a copy of the `config/client_secret.yml` from the staging secrets
2. Make sure you have a clean working tree (eg. `git status` shows no changes)
3. Run `bundle exec ./script/update_data_files.sh` script following its instructions
4. Review changes to the `data/administrative_units.json` file (eg. `git diff`)
5. Commit changes

Once committed and pushed upstream, to see the changes will require a deploy of the applications.
