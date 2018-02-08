# aspec_rb

[![Gem Version](https://badge.fury.io/rb/aspec_rb.svg)](https://badge.fury.io/rb/aspec_rb)
[![Build Status](https://travis-ci.org/bsmith-n4/aspec_rb.svg?branch=master)](https://travis-ci.org/bsmith-n4/aspec_rb)

## Installation

```
gem install aspec_rb
```

## Usage 

```
asciidoctor -r aspec_rb index.adoc
```

## Development

To build a local copy of the gem to the `pkg` directory:

```
rake build
``` 

To install from a local build:

```
gem install pkg/aspec_rb<version>.gem 
```

To release a new version, edit the version number in `lib/aspec_rb/version.rb`, run bundle install to regenerate the `Gemfile.lock`.
To release this version, use `rake release` command, providing all has been committed. This command builds the gem to the pkg directory in preparation for a push to Rubygems.org.

### Testing

Tests can be run using rake:

```
rake test
```
