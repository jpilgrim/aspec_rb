# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'test/unit'

task default: :test

task :test do
  ruby 'test/suite.rb'
end

task :rubocop do
  sh 'rubocop'
end
