# frozen_string_literal: true

# Use this to set global versioning for the RubyGem
module AspecRb
  # Publish step is done automatically when a new version
  # lands on master and Travis CI tests are green - https://travis-ci.org/tcob/aspec_rb
  # For this deploy config, see https://github.com/tcob/aspec_rb/blob/master/.travis.yml
  #
  # Manual release can be performed by running 'bundle install && rake release'
  VERSION = '0.0.7'
end
