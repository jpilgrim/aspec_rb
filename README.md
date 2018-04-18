# aspec_rb

[![Gem Version](https://badge.fury.io/rb/aspec_rb.svg)](https://badge.fury.io/rb/aspec_rb)
[![Build Status](https://travis-ci.org/tcob/aspec_rb.svg?branch=master)](https://travis-ci.org/tcob/aspec_rb)
[![Test Coverage](https://api.codeclimate.com/v1/badges/11ef540aabef88117720/test_coverage)](https://codeclimate.com/github/tcob/aspec_rb/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/11ef540aabef88117720/maintainability)](https://codeclimate.com/github/tcob/aspec_rb/maintainability)

## Installation

Install using Rubygems.org:

```
gem install aspec_rb
```

## Usage 

```
asciidoctor -r aspec_rb index.adoc
```

## Development

To build a local copy of the gem:

```
rake build
``` 

To install from a local build:

```
gem install pkg/aspec_rb<your_version>.gem 
```

### Deployment

To release a new version, edit the version number in `lib/aspec_rb/version.rb` and run `bundle install`.
Publishing to Rubygems.org is done automatically when a new version is detected on the master branch and Travis builds are green.

### Testing

Tests can be run using rake:

```
rake test
```
